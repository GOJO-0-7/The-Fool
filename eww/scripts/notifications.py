#!/usr/bin/env python3
import os
import sys
import json
import time
import re
import subprocess
import warnings

warnings.filterwarnings("ignore", category=DeprecationWarning)

import gi
gi.require_version('Gio', '2.0')
gi.require_version('GLib', '2.0')
from gi.repository import Gio, GLib

CACHE_FILE = os.path.expanduser("~/.cache/eww_dashboard_notifs.json")

NODE_INFO = Gio.DBusNodeInfo.new_for_xml("""
<node>
  <interface name="org.freedesktop.Notifications">
    <method name="GetCapabilities">
      <arg type="as" name="capabilities" direction="out"/>
    </method>
    <method name="Notify">
      <arg type="s" name="app_name" direction="in"/>
      <arg type="u" name="replaces_id" direction="in"/>
      <arg type="s" name="app_icon" direction="in"/>
      <arg type="s" name="summary" direction="in"/>
      <arg type="s" name="body" direction="in"/>
      <arg type="as" name="actions" direction="in"/>
      <arg type="a{sv}" name="hints" direction="in"/>
      <arg type="i" name="expire_timeout" direction="in"/>
      <arg type="u" name="id" direction="out"/>
    </method>
    <method name="GetServerInformation">
      <arg type="s" name="name" direction="out"/>
      <arg type="s" name="vendor" direction="out"/>
      <arg type="s" name="version" direction="out"/>
      <arg type="s" name="spec_version" direction="out"/>
    </method>
  </interface>
</node>
""").interfaces[0]

def strip_html(text):
    if not text:
        return ""
    clean = re.sub(r'<[^>]+>', '', text)
    return clean.strip()

def unpack_variant(val):
    if isinstance(val, GLib.Variant):
        return val.unpack()
    return val

class NotificationDaemon:
    def __init__(self):
        self.current_id = 1
        self.timer_id = None

    def hide_popup(self):
        subprocess.run(["eww", "update", "notif_active=false"], check=False)
        self.timer_id = None
        return False

    def save_to_cache(self, app_name, title, body, icon=""):
        notifs = []
        if os.path.exists(CACHE_FILE):
            try:
                with open(CACHE_FILE, "r") as f:
                    notifs = json.load(f)
            except Exception:
                notifs = []

        new_id = max([n.get("id", 0) for n in notifs], default=0) + 1
        current_time = time.strftime("%I:%M %p")

        new_item = {
            "id": new_id,
            "app": app_name or "System",
            "time": current_time,
            "title": title or "",
            "body": body or "",
            "icon": icon or ""
        }

        notifs.insert(0, new_item)
        notifs = notifs[:50]

        try:
            os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
            with open(CACHE_FILE, "w") as f:
                json.dump(notifs, f, indent=2)
        except Exception as e:
            print(f"Error saving to cache: {e}", file=sys.stderr)

    def is_battery_notification(self, app_name, summary, body, app_icon, hints):
        desktop_entry = ""
        if "desktop-entry" in hints:
            desktop_entry = str(unpack_variant(hints["desktop-entry"])).lower()

        search_target = f"{app_name} {summary} {body} {app_icon} {desktop_entry}".lower()

        # Extended Battery and Charger Filter Keywords
        battery_keywords = [
            "battery", "charger", "charging", "discharging",
            "power", "upower", "xfce4-power-manager", "mate-power-manager",
            "gnome-power-manager", "low battery", "plugged in", "unplugged",
            "fully charged", "battery low", "battery critical",
            "charger connected", "charger disconnected", "ac adapter", "ac power"
        ]

        for kw in battery_keywords:
            if kw in search_target:
                return True

        return False

    def normalize_app_name(self, raw_app, hints):
        desktop_entry = ""
        if "desktop-entry" in hints:
            desktop_entry = str(unpack_variant(hints["desktop-entry"])).lower()

        identifier = (raw_app or desktop_entry or "").lower()

        if "networkmanager" in identifier or "nm-applet" in identifier:
            return "Network"
        elif "whatsapp" in identifier:
            return "WhatsApp"
        elif "discord" in identifier:
            return "Discord"
        elif "telegram" in identifier:
            return "Telegram"
        elif "spotify" in identifier:
            return "Spotify"
        elif "slack" in identifier:
            return "Slack"
        elif "chrome" in identifier:
            return "Google Chrome"
        elif "firefox" in identifier:
            return "Firefox"
        elif "brave" in identifier:
            return "Brave"
        elif "edge" in identifier:
            return "MS Edge"
        elif "code" in identifier or "vscode" in identifier:
            return "VS Code"

        if raw_app and raw_app.strip():
            return raw_app.strip().capitalize()
        elif desktop_entry:
            return desktop_entry.capitalize()

        return "System"

    def notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, timeout):
        unpacked_hints = {}
        if hints:
            for k, v in hints.items():
                unpacked_hints[k] = unpack_variant(v)

        summary = strip_html(summary)
        body = strip_html(body)

        # STRICT BATTERY AND CHARGER FILTERING
        if self.is_battery_notification(app_name, summary, body, app_icon, unpacked_hints):
            notif_id = replaces_id if replaces_id > 0 else self.current_id
            if replaces_id == 0:
                self.current_id += 1
            return notif_id

        final_app_name = self.normalize_app_name(app_name, unpacked_hints)

        # -----------------------------------------------------
        # NEW: Ignore Network notifications (Handled by custom listener)
        # -----------------------------------------------------
        if final_app_name == "Network":
            notif_id = replaces_id if replaces_id > 0 else self.current_id
            if replaces_id == 0:
                self.current_id += 1
            return notif_id
        # -----------------------------------------------------

        notif_id = replaces_id if replaces_id > 0 else self.current_id
        if replaces_id == 0:
            self.current_id += 1

        self.save_to_cache(final_app_name, summary, body, app_icon)

        notif_data = {
            "app": final_app_name.upper(),
            "summary": summary,
            "body": body,
            "icon": app_icon or ""
        }

        json_str = json.dumps(notif_data)
        subprocess.run(["eww", "update", f"notif_data={json_str}", "notif_active=true"], check=False)

        if self.timer_id is not None:
            GLib.source_remove(self.timer_id)
            self.timer_id = None

        duration = 5 if timeout <= 0 else max(1, int(timeout / 1000))
        self.timer_id = GLib.timeout_add_seconds(duration, self.hide_popup)

        return notif_id

daemon = NotificationDaemon()

def handle_method_call(connection, sender, object_path, interface_name, method_name, parameters, invocation):
    if method_name == "GetCapabilities":
        invocation.return_value(GLib.Variant("(as)", [["body", "body-markup", "actions", "icon-static"]]))
    elif method_name == "GetServerInformation":
        invocation.return_value(GLib.Variant("(ssss)", ["EwwPopup", "Eww", "1.0", "1.2"]))
    elif method_name == "Notify":
        app_name, replaces_id, app_icon, summary, body, actions, hints, timeout = parameters.unpack()
        nid = daemon.notify(app_name, replaces_id, app_icon, summary, body, actions, hints, timeout)
        invocation.return_value(GLib.Variant("(u)", (nid,)))

if __name__ == "__main__":
    Gio.bus_own_name(
        Gio.BusType.SESSION,
        "org.freedesktop.Notifications",
        Gio.BusNameOwnerFlags.REPLACE,
        lambda conn, name: conn.register_object("/org/freedesktop/Notifications", NODE_INFO, handle_method_call),
        None,
        None
    )
    loop = GLib.MainLoop()
    try:
        loop.run()
    except KeyboardInterrupt:
        pass

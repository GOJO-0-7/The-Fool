#!/usr/bin/env python3
import os
import sys
import json
import glob
import subprocess
from configparser import ConfigParser

# GTK Theme Icon Lookup Initializer
try:
    import gi
    gi.require_version('Gtk', '3.0')
    from gi.repository import Gtk
    gtk_theme = Gtk.IconTheme.get_default()
except Exception:
    gtk_theme = None

def resolve_icon_path(icon_name):
    if not icon_name:
        return ""
    # ১. আইকনটি ইতোমধ্যে ডিরেক্ট ফাইল পাথ হলে
    if os.path.isabs(icon_name) and os.path.exists(icon_name):
        return icon_name
    
    # ২. GTK Icon Theme দিয়ে আসল ফাইল পাথ খোঁজা
    if gtk_theme:
        try:
            icon_info = gtk_theme.lookup_icon(icon_name, 48, 0)
            if icon_info:
                path = icon_info.get_filename()
                if path and os.path.exists(path):
                    return path
        except Exception:
            pass

    # ৩. ম্যানুয়াল ফোল্ডার সার্চ (Fallback)
    search_dirs = [
        "/usr/share/pixmaps",
        "/usr/share/icons/hicolor/scalable/apps",
        "/usr/share/icons/hicolor/48x48/apps",
        "/usr/share/icons/hicolor/128x128/apps",
        os.path.expanduser("~/.local/share/icons")
    ]
    for d in search_dirs:
        for ext in [".png", ".svg", ".xpm"]:
            test_path = os.path.join(d, icon_name + ext)
            if os.path.exists(test_path):
                return test_path

    return ""

CACHE_FILE = os.path.expanduser("~/.cache/eww_app_freq.json")

def load_freq():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

def save_freq(freq):
    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    with open(CACHE_FILE, "w") as f:
        json.dump(freq, f)

def get_apps():
    freq = load_freq()
    apps = []
    dirs = ['/usr/share/applications', os.path.expanduser('~/.local/share/applications')]
    seen = set()

    for d in dirs:
        for filepath in glob.glob(os.path.join(d, '*.desktop')):
            config = ConfigParser(interpolation=None)
            try:
                config.read(filepath, encoding='utf-8')
                if 'Desktop Entry' in config:
                    entry = config['Desktop Entry']
                    if entry.get('NoDisplay') == 'true' or entry.get('Type') != 'Application':
                        continue
                    name = entry.get('Name')
                    exec_cmd = entry.get('Exec', '').split('%')[0].strip()
                    raw_icon = entry.get('Icon', '')
                    icon_path = resolve_icon_path(raw_icon)
                    
                    if name and exec_cmd and name not in seen:
                        seen.add(name)
                        count = freq.get(name, 0)
                        apps.append({
                            'name': name,
                            'exec': exec_cmd,
                            'icon': icon_path,
                            'count': count
                        })
            except Exception:
                continue

    return sorted(apps, key=lambda x: (-x['count'], x['name'].lower()))

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "launch":
        app_name = sys.argv[2]
        cmd = sys.argv[3]
        freq = load_freq()
        freq[app_name] = freq.get(app_name, 0) + 1
        save_freq(freq)
        subprocess.Popen(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        print(json.dumps(get_apps()))

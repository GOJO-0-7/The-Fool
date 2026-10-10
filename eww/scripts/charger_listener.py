#!/usr/bin/env python3
import time
import os
import glob
import subprocess
import threading

def get_ac_path():
    ac_paths = glob.glob("/sys/class/power_supply/AC*/online") + \
               glob.glob("/sys/class/power_supply/ACAD*/online") + \
               glob.glob("/sys/class/power_supply/ADP*/online")
    return ac_paths[0] if ac_paths else None

def get_battery_capacity():
    bat_paths = glob.glob("/sys/class/power_supply/BAT*/capacity")
    if bat_paths:
        try:
            with open(bat_paths[0], "r") as f:
                return int(f.read().strip())
        except Exception:
            pass
    return 100

def get_battery_icon(capacity, is_charging):
    """Nerd Font 3.0+ Dynamic Battery Icons based on exact charge level"""
    if is_charging:
        if capacity >= 95: return "󰂅"
        elif capacity >= 85: return "󰂋"
        elif capacity >= 75: return "󰂊"
        elif capacity >= 65: return "󰢞"
        elif capacity >= 55: return "󰂉"
        elif capacity >= 45: return "󰢝"
        elif capacity >= 35: return "󰂈"
        elif capacity >= 25: return "󰂇"
        elif capacity >= 15: return "󰂆"
        else: return "󰢜"
    else:
        if capacity <= 10: return "󰂃"
        elif capacity <= 20: return "󰁻"
        elif capacity <= 30: return "󰁼"
        elif capacity <= 40: return "󰁽"
        elif capacity <= 50: return "󰁾"
        elif capacity <= 60: return "󰁿"
        elif capacity <= 70: return "󰂀"
        elif capacity <= 80: return "󰂁"
        elif capacity <= 90: return "󰂂"
        else: return "󰁹"

def _run_osd_thread(icon, label, value, duration, urgency="normal"):
    """Non-blocking EWW OSD & Desktop Notification sender"""
    # 1. Update EWW OSD Widget
    subprocess.run([
        "eww", "update",
        f"osd_icon={icon}",
        f"osd_label={label}",
        f"osd_value={value}",
        "osd_type=bar",
        "osd_active=true"
    ], check=False)

    # 2. Desktop Notification via notify-send (if daemon present)
    try:
        subprocess.run([
            "notify-send",
            "-u", urgency,
            "-a", "Power Manager",
            f"{icon}  {label}",
            f"Battery Level: {value}%"
        ], check=False)
    except Exception:
        pass
    
    time.sleep(duration)
    
    subprocess.run([
        "eww", "update",
        "osd_active=false"
    ], check=False)

def show_osd(icon, label, value, duration=2.5, urgency="normal"):
    threading.Thread(
        target=_run_osd_thread, 
        args=(icon, label, value, duration, urgency), 
        daemon=True
    ).start()

def main():
    ac_file = get_ac_path()
    last_state = None
    last_warned_level = None
    thresholds = [5, 10, 15, 20]

    while True:
        try:
            current_state = "0"
            if ac_file and os.path.exists(ac_file):
                with open(ac_file, "r") as f:
                    current_state = f.read().strip()

            cap = get_battery_capacity()
            is_charging = (current_state == "1")

            # ১. চার্জার প্লাগ-ইন বা প্লাগ-আউট ইভেন্ট
            if last_state is not None and current_state != last_state:
                if is_charging:
                    icon = get_battery_icon(cap, is_charging=True)
                    show_osd(icon, f"Charger Connected ({cap}%)", cap, duration=2.5, urgency="normal")
                    last_warned_level = None  # চার্জে দিলে ওয়ার্নিং ফ্ল্যাগ রিসেট হবে
                else:
                    show_osd("󰚥", f"Charger Disconnected ({cap}%)", cap, duration=2.5, urgency="normal")

            # ২. লো ব্যাটারি ওয়ার্নিং (শুধুমাত্র চার্জার খোলা অবস্থায়)
            if not is_charging:
                current_threshold = None
                for limit in thresholds:
                    if cap <= limit:
                        current_threshold = limit
                        break

                if current_threshold is not None:
                    if last_warned_level is None or last_warned_level > current_threshold:
                        icon = get_battery_icon(cap, is_charging=False)
                        urgency_level = "critical" if current_threshold <= 10 else "normal"
                        show_osd(
                            icon, 
                            f"Low Battery ({cap}% Remaining)", 
                            cap, 
                            duration=4.0, 
                            urgency=urgency_level
                        )
                        last_warned_level = current_threshold

            last_state = current_state
        except Exception:
            pass

        time.sleep(2)

if __name__ == "__main__":
    main()

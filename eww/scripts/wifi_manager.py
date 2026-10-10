#!/usr/bin/env python3
import json
import subprocess
import sys

def get_wifi_list():
    try:
        out = subprocess.check_output(
            ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi"],
            text=True
        )
        networks = []
        seen = set()
        for line in out.strip().split("\n"):
            if not line:
                continue
            parts = line.split(":")
            if len(parts) >= 4:
                in_use = (parts[0] == "*")
                ssid = parts[1]
                signal = parts[2]
                security = parts[3] if parts[3] else "Open"
                
                if ssid and ssid not in seen:
                    seen.add(ssid)
                    sig_val = int(signal) if signal.isdigit() else 50
                    if sig_val > 75: icon = "󰤨"
                    elif sig_val > 50: icon = "󰤥"
                    elif sig_val > 25: icon = "󰤢"
                    else: icon = "󰤟"
                    
                    networks.append({
                        "ssid": ssid,
                        "signal": f"{signal}%",
                        "security": security,
                        "active": in_use,
                        "icon": icon
                    })
        return json.dumps(networks[:8])
    except Exception:
        return json.dumps([])

def connect_wifi(ssid, password=""):
    cmd = ["nmcli", "dev", "wifi", "connect", ssid]
    if password:
        cmd.extend(["password", password])
    subprocess.run(cmd)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "list":
        print(get_wifi_list())
    elif len(sys.argv) > 2 and sys.argv[1] == "connect":
        connect_wifi(sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else "")

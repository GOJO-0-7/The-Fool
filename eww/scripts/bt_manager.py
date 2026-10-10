#!/usr/bin/env python3
import subprocess
import json
import sys

def get_devices():
    try:
        output = subprocess.check_output(["bluetoothctl", "devices"], text=True)
        devices = []
        for line in output.strip().split('\n'):
            if not line:
                continue
            parts = line.split(' ', 2)
            if len(parts) >= 3:
                devices.append({
                    "mac": parts[1],
                    "name": parts[2]
                })
        return json.dumps(devices)
    except Exception:
        return json.dumps([])

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "list":
        print(get_devices())
    else:
        print(json.dumps([]))

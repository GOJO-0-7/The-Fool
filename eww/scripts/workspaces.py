#!/usr/bin/env python3
import os
import sys
import json
import socket
import subprocess

def get_workspaces():
    try:
        active_raw = subprocess.check_output(["hyprctl", "activeworkspace", "-j"]).decode("utf-8")
        active_id = json.loads(active_raw).get("id", 1)
    except Exception:
        active_id = 1

    try:
        ws_raw = subprocess.check_output(["hyprctl", "workspaces", "-j"]).decode("utf-8")
        occupied_ids = {w["id"] for w in json.loads(ws_raw) if w["id"] > 0}
    except Exception:
        occupied_ids = set()

    workspaces = []
    # Generates workspaces 1 through 9
    for i in range(1, 10):
        workspaces.append({
            "id": i,
            "active": (i == active_id),
            "occupied": (i in occupied_ids)
        })
    return workspaces

def main():
    # Initial print for Eww start
    print(json.dumps(get_workspaces()), flush=True)

    # Connect to Hyprland IPC socket
    his = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    xdg_runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    
    if not his:
        return

    sock_path = os.path.join(xdg_runtime, "hypr", his, ".socket2.sock")
    if not os.path.exists(sock_path):
        return

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(sock_path)
    
    buffer = ""
    while True:
        data = sock.recv(4096).decode("utf-8", errors="ignore")
        if not data:
            break
        buffer += data
        lines = buffer.split("\n")
        buffer = lines.pop()
        
        updated = False
        for line in lines:
            if any(line.startswith(e) for e in ["workspace>>", "focusedmon>>", "createworkspace>>", "destroyworkspace>>"]):
                updated = True
                break
        
        if updated:
            print(json.dumps(get_workspaces()), flush=True)

if __name__ == "__main__":
    main()

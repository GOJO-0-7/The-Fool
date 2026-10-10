#!/usr/bin/env python3
import sys
import json
import time
import os

STATE_FILE = "/tmp/eww_timer_state.json"

def load_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {"duration": 300, "remaining": 300, "running": False, "last_update": time.time()}

def save_state(state):
    with open(STATE_FILE, "w") as f:
        json.dump(state, f)

def get_status():
    state = load_state()
    now = time.time()
    
    if state["running"]:
        elapsed = now - state["last_update"]
        state["remaining"] = max(0, state["remaining"] - elapsed)
        state["last_update"] = now
        if state["remaining"] <= 0:
            state["running"] = False
        save_state(state)
    
    rem = int(state["remaining"])
    m, s = divmod(rem, 60)
    h, m = divmod(m, 60)
    time_str = f"{h:02d}:{m:02d}:{s:02d}" if h > 0 else f"{m:02d}:{s:02d}"
    
    total = state["duration"] if state["duration"] > 0 else 1
    progress = int(((state["duration"] - rem) / total) * 100)
    progress = max(0, min(100, progress))

    return {
        "time": time_str,
        "running": state["running"],
        "remaining": rem,
        "progress": progress
    }

def toggle():
    state = load_state()
    if state["remaining"] <= 0:
        state["remaining"] = state["duration"] if state["duration"] > 0 else 300
    state["running"] = not state["running"]
    state["last_update"] = time.time()
    save_state(state)

def reset():
    state = load_state()
    state["running"] = False
    state["remaining"] = state["duration"] if state["duration"] > 0 else 300
    state["last_update"] = time.time()
    save_state(state)

def add_time(secs):
    state = load_state()
    state["remaining"] = max(0, state["remaining"] + secs)
    if state["remaining"] > state["duration"]:
        state["duration"] = state["remaining"]
    if state["remaining"] <= 0:
        state["running"] = False
    state["last_update"] = time.time()
    save_state(state)

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    if cmd == "status":
        print(json.dumps(get_status()))
    elif cmd == "toggle":
        toggle()
        print(json.dumps(get_status()))
    elif cmd == "reset":
        reset()
        print(json.dumps(get_status()))
    elif cmd == "add":
        secs = int(sys.argv[2]) if len(sys.argv) > 2 else 60
        add_time(secs)
        print(json.dumps(get_status()))

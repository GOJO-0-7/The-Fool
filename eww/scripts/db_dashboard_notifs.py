#!/usr/bin/env python3
import os
import sys
import json
import time

CACHE_FILE = os.path.expanduser("~/.cache/eww_dashboard_notifs.json")

def load_notifs():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return []
    return []

def save_notifs(data):
    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    with open(CACHE_FILE, "w") as f:
        json.dump(data, f, indent=2)

def add_notif(app, title, body):
    notifs = load_notifs()
    # আইডি জেনারেট করা
    new_id = max([n.get("id", 0) for n in notifs], default=0) + 1
    
    new_item = {
        "id": new_id,
        "app": app,
        "time": "Just now",
        "title": title,
        "body": body
    }
    
    # নতুন নোটিফিকেশন সবার শুরুতে রাখতে insert(0, ...)
    notifs.insert(0, new_item)
    save_notifs(notifs)
    return notifs

if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "get"
    
    if action == "get":
        print(json.dumps(load_notifs()))
        
    elif action == "add" and len(sys.argv) >= 5:
        # ব্যবহারবিধি: python3 db_dashboard_notifs.py add "AppName" "Title" "Body"
        app = sys.argv[2]
        title = sys.argv[3]
        body = sys.argv[4]
        print(json.dumps(add_notif(app, title, body)))
        
    elif action == "clear":
        save_notifs([])
        print(json.dumps([]))
        
    elif action == "remove" and len(sys.argv) > 2:
        nid = int(sys.argv[2])
        notifs = [n for n in load_notifs() if n["id"] != nid]
        save_notifs(notifs)
        print(json.dumps(notifs))

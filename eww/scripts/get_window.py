#!/usr/bin/env python3
import json
import re
import subprocess


def get_window_title():
    try:
        # Hyprland active window info
        output = subprocess.check_output(["hyprctl", "activewindow", "-j"]).decode(
            "utf-8"
        )
        data = json.loads(output)

        title = data.get("title", "")
        wm_class = data.get("class", "")

        if not title and not wm_class:
            return "Desktop"

        # Match korar jonno Full String
        full_str = f"{title} - {wm_class}" if wm_class else title

        # Apnar Regex Rules List
        rules = [
            (r" - $", ""),
            (r"(.*?) - Chromium - chromium", r"   \1 "),
            (r"(.*chrome)...(.*)", r"   \1 "),
            (r"(.*) - Obsidian - .* - obsidian", r" 󰠮  \1 "),
            (r"(.*nvim)...(.*)", r"   \2 "),
            (r"(.*code) - (.*)", r" 󰨞  \1 "),
            (r"^.*btop( .*|$)", r" 󰧨   BTOP \1 "),
            (r"^.*unimatrix( .*|$)", r" 󰘨 MATRIX \1 "),
            (r"(.*) - Spotify", r"  \1 "),
            (r"(.*) - com.mitchellh.ghostty", r" 󰊠 \1 "),
            (r"(.*) - Alacritty", r"   \1 "),
            (r"(.*) - kitty", r"   \1 "),
            (r"(.*) - BeeperTexts", r" 󰻞  \1 "),
            (r"(.*Discord)...(.*).. (.*)", r"   \2 "),
            (r"(.*) - org.gnome.Nautilus", r" 󰉓  \1 "),
            (r"(.*) - fish", r"   [\1] "),
            (r"(.*Steam)...(.*)", r"   \1"),
            (r"(.*imv)...(.*).. (.*)", r"   \2"),
            (r"(.*) - com.obsproject.Studio", r"  \1 "),
        ]

        # Match check & rewrite
        for pattern, repl in rules:
            if re.search(pattern, full_str, re.IGNORECASE):
                return re.sub(pattern, repl, full_str).strip()

        # Konorokom rule match na korle direct title ferot dibe
        return title
    except Exception:
        return "Desktop"


if __name__ == "__main__":
    print(get_window_title())

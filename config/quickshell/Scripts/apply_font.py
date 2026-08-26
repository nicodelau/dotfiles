#!/usr/bin/env python3
import configparser
import os
import re
import subprocess
import sys

if len(sys.argv) < 3:
    print("Usage: apply_font.py <FontName> <FontSize>")
    sys.exit(1)

font_name = sys.argv[1]
font_size = sys.argv[2]
home = os.environ.get("HOME", "")
full_font = f"{font_name} {font_size}"

# 1. Update GTK globally via gsettings
subprocess.run(
    ["gsettings", "set", "org.gnome.desktop.interface", "font-name", full_font]
)

# 2. Update GTK 3 and 4 settings.ini
for gtk_ver in ["gtk-3.0", "gtk-4.0"]:
    ini_path = os.path.join(home, ".config", gtk_ver, "settings.ini")
    if os.path.exists(ini_path):
        with open(ini_path, "r") as f:
            lines = f.readlines()
        with open(ini_path, "w") as f:
            for line in lines:
                if line.startswith("gtk-font-name="):
                    f.write(f"gtk-font-name={full_font}\n")
                else:
                    f.write(line)


# 4. Update qt5ct and qt6ct
for qtct in ["qt5ct", "qt6ct"]:
    qtct_conf = os.path.join(home, ".config", qtct, f"{qtct}.conf")
    if os.path.exists(qtct_conf):
        config = configparser.ConfigParser()
        config.optionxform = str  # Preserve case
        config.read(qtct_conf)
        if "Fonts" not in config:
            config["Fonts"] = {}

        font_str = f"{font_name},{font_size},-1,5,50,0,0,0,0,0"
        config["Fonts"]["general"] = f'"{font_str}"'
        with open(qtct_conf, "w") as configfile:
            config.write(configfile)

# 5. Update Hyprland groupbar font
import json

update_script = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "update_hypr_prefs.py"
)
if os.path.exists(update_script):
    hypr_args = {
        "group": {
            "groupbar": {"font_family": f'"{font_name}"', "font_size": int(font_size)}
        }
    }
    subprocess.run(["python3", update_script, json.dumps(hypr_args)])
    subprocess.run(["hyprctl", "reload"])

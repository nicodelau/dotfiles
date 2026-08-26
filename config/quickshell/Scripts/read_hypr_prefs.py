#!/usr/bin/env python3
import json
import subprocess

options = [
    "decoration:blur:enabled",
    "decoration:rounding",
    "decoration:active_opacity",
    "decoration:inactive_opacity",
    "decoration:blur:size",
    "decoration:blur:passes",
    "general:gaps_in",
    "general:gaps_out",
    "general:border_size",
    "decoration:shadow:enabled",
    "decoration:shadow:range",
    "decoration:shadow:render_power",
    "animations:enabled",
]

res = {}
try:
    for opt in options:
        out = subprocess.check_output(["hyprctl", "getoption", opt, "-j"]).decode()
        data = json.loads(out)
        # the key could be "int", "float", "bool", "str"
        if "int" in data:
            res[opt] = data["int"]
        elif "float" in data:
            res[opt] = data["float"]
        elif "bool" in data:
            res[opt] = data["bool"]
        elif "str" in data:
            res[opt] = data["str"]
        elif "custom" in data:
            res[opt] = data["custom"]
        elif "css" in data:
            # Assuming gaps "4 4 4 4" or just "4"
            parts = str(data["css"]).split()
            if len(parts) > 0:
                res[opt] = int(parts[0])
except Exception as e:
    res["error"] = str(e)

print(json.dumps(res))

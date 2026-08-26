#!/usr/bin/env python3
import json
import os
import subprocess
import sys


def sanitize_color(c):
    s = str(c)
    if s.startswith("#") and len(s) > 7:
        return "#" + s[-6:]
    return s


def get_brightness(c):
    s = str(c)
    r, g, b = 0, 0, 0
    if s.startswith("#"):
        if len(s) == 7:
            r = int(s[1:3], 16) / 255.0
            g = int(s[3:5], 16) / 255.0
            b = int(s[5:7], 16) / 255.0
        elif len(s) == 9:
            r = int(s[3:5], 16) / 255.0
            g = int(s[5:7], 16) / 255.0
            b = int(s[7:9], 16) / 255.0
        elif len(s) == 4:
            r = int(s[1:2] * 2, 16) / 255.0
            g = int(s[2:3] * 2, 16) / 255.0
            b = int(s[3:4] * 2, 16) / 255.0
    return r * 0.299 + g * 0.587 + b * 0.114


def hypr_color(c, alpha=""):
    s = str(c)
    if s.startswith("#"):
        s = s[1:]
    if len(s) == 8:
        a = s[0:2]
        rgb = s[2:]
        if alpha:
            return f"rgba({rgb}{alpha})"
        else:
            return f"rgb({rgb})"
    if alpha:
        return f"rgba({s}{alpha})"
    else:
        return f"rgb({s})"


def main():
    home = os.environ.get("HOME", "")
    cache_file = os.path.join(home, ".cache", "quickshell", "colorscheme.json")

    if not os.path.exists(cache_file):
        print("Colorscheme cache not found.")
        return

    with open(cache_file, "r") as f:
        colors = json.load(f)

    bg = colors.get("bg", "#000000")
    fg = colors.get("fg", "#ffffff")

    def blend_hex(f_hex, b_hex, w):
        f, b = f_hex.lstrip("#"), b_hex.lstrip("#")
        if len(f) == 3:
            f = "".join(c * 2 for c in f)
        if len(b) == 3:
            b = "".join(c * 2 for c in b)
        if len(f) > 6:
            f = f[-6:]
        if len(b) > 6:
            b = b[-6:]
        if len(f) != 6 or len(b) != 6:
            return b_hex
        rf, gf, bf = int(f[0:2], 16), int(f[2:4], 16), int(f[4:6], 16)
        rb, gb, bb = int(b[0:2], 16), int(b[2:4], 16), int(b[4:6], 16)
        return f"#{int(rf*w + rb*(1-w)):02x}{int(gf*w + gb*(1-w)):02x}{int(bf*w + bb*(1-w)):02x}"

    bgSecondary = colors.get("bgSecondary", blend_hex(fg, bg, 0.05))
    if len(str(bgSecondary)) > 7:
        bgSecondary = blend_hex(fg, bg, 0.05)
    fg = colors.get("fg", "#ffffff")
    muted = colors.get("muted", "#888888")
    border = colors.get("border", "#444444")
    accent = colors.get("accent", "#a77ef5")
    accentComplementary = colors.get("accentComplementary", "#f57eb6")
    shadow = colors.get("shadow", "#000000")
    name = colors.get("name", "Default")

    brightness = get_brightness(bg)
    is_dark = brightness <= 0.5

    # 1. Kitty
    kitty_theme = f"""foreground              {fg}
background              {bg}
selection_foreground    {bg}
selection_background    {accent}
cursor                  {fg}
cursor_text_color       {bg}
url_color               {accent}
active_border_color     {accent}
inactive_border_color   {muted}
bell_border_color       {accent}
active_tab_foreground   {bg}
active_tab_background   {accent}
inactive_tab_foreground {fg}
inactive_tab_background {bg}
tab_bar_background      {bg}
color0  {muted}
color8  {muted}
color1  {accent}
color9  {accent}
color2  {accent}
color10 {accent}
color3  {accent}
color11 {accent}
color4  {accent}
color12 {accent}
color5  {accent}
color13 {accent}
color6  {accent}
color14 {accent}
color7  {fg}
color15 {fg}
color16 {bgSecondary}
"""
    kitty_dir = os.path.join(home, ".config", "kitty")
    os.makedirs(kitty_dir, exist_ok=True)
    with open(os.path.join(kitty_dir, "theme.conf"), "w") as f:
        f.write(kitty_theme)

    subprocess.run("kill -SIGUSR1 $(pidof kitty) 2>/dev/null", shell=True)

    # 2. GTK
    mapping = {
        "primary": accent,
        "on_primary": bg,
        "primary_container": bgSecondary,
        "on_primary_container": accent,
        "inverse_primary": bg,
        "primary_fixed": accent,
        "primary_fixed_dim": accent,
        "on_primary_fixed": bg,
        "on_primary_fixed_variant": accent,
        "secondary": fg,
        "on_secondary": bg,
        "secondary_container": bgSecondary,
        "on_secondary_container": fg,
        "secondary_fixed": fg,
        "secondary_fixed_dim": fg,
        "on_secondary_fixed": bg,
        "on_secondary_fixed_variant": fg,
        "tertiary": accentComplementary,
        "on_tertiary": bg,
        "tertiary_container": bgSecondary,
        "on_tertiary_container": accentComplementary,
        "tertiary_fixed": accentComplementary,
        "tertiary_fixed_dim": accentComplementary,
        "on_tertiary_fixed": bg,
        "on_tertiary_fixed_variant": accentComplementary,
        "error": fg,
        "on_error": "#ffffff",
        "error_container": bgSecondary,
        "on_error_container": fg,
        "background": bg,
        "on_background": fg,
        "surface": bg,
        "on_surface": fg,
        "surface_dim": bg,
        "surface_bright": bgSecondary,
        "surface_container_lowest": bg,
        "surface_container_low": bgSecondary,
        "surface_container": bgSecondary,
        "surface_container_high": bgSecondary,
        "surface_container_highest": bgSecondary,
        "surface_variant": bgSecondary,
        "on_surface_variant": muted,
        "surface_tint": bg,
        "outline": border,
        "outline_variant": border,
        "inverse_surface": fg,
        "inverse_on_surface": bg,
        "shadow": shadow,
        "scrim": shadow,
        "source_color": accent,
        "accent": accent,
    }

    gtk4_colors = ":root {\n"
    for k, v in mapping.items():
        gtk4_colors += f"  --{k}: {sanitize_color(v)};\n"
    gtk4_colors += "}\n\nselection,\n:selected {\n  background-color: var(--accent);\n  color: var(--bg);\n}\n"
    gtk4_colors += "\n.background,\niconview:not(:selected),\n.view:not(:selected) {\n  color: var(--on_surface);\n}\n"

    gtk3_colors = ""
    for k, v in mapping.items():
        gtk3_colors += f"@define-color {k} {sanitize_color(v)};\n"
    gtk3_colors += (
        "\nselection,\n:selected {\n  background-color: @accent;\n  color: @bg;\n}\n"
    )
    gtk3_colors += "\n.background,\niconview:not(:selected),\n.view:not(:selected) {\n  color: @on_surface;\n}\n"

    theme_dir = os.path.join(home, ".themes", "Material-Gnome")
    os.makedirs(os.path.join(theme_dir, "gtk-3.0"), exist_ok=True)
    os.makedirs(os.path.join(theme_dir, "gtk-4.0"), exist_ok=True)
    os.makedirs(os.path.join(home, ".config", "gtk-3.0"), exist_ok=True)
    os.makedirs(os.path.join(home, ".config", "gtk-4.0"), exist_ok=True)

    with open(os.path.join(theme_dir, "gtk-4.0", "colors.css"), "w") as f:
        f.write(gtk4_colors)
    with open(os.path.join(theme_dir, "gtk-3.0", "colors.css"), "w") as f:
        f.write(gtk3_colors)

    os.system(f"ln -sf '{theme_dir}/gtk-3.0/gtk.css' '{home}/.config/gtk-3.0/gtk.css'")
    os.system(
        f"ln -sf '{theme_dir}/gtk-3.0/colors.css' '{home}/.config/gtk-3.0/colors.css'"
    )
    os.system(f"ln -sf '{theme_dir}/gtk-4.0/gtk.css' '{home}/.config/gtk-4.0/gtk.css'")
    os.system(
        f"ln -sf '{theme_dir}/gtk-4.0/gtk-dark.css' '{home}/.config/gtk-4.0/gtk-dark.css'"
    )
    os.system(
        f"ln -sf '{theme_dir}/gtk-4.0/colors.css' '{home}/.config/gtk-4.0/colors.css'"
    )
    os.system(
        f"touch '{theme_dir}/gtk-3.0/gtk.css' '{theme_dir}/gtk-3.0/gtk-dark.css' 2>/dev/null"
    )
    os.system(
        f"touch '{home}/.config/gtk-4.0/gtk.css' '{home}/.config/gtk-4.0/gtk-dark.css' 2>/dev/null"
    )

    gs_val = "prefer-dark" if is_dark else "prefer-light"
    opp_val = "prefer-light" if is_dark else "prefer-dark"
    dark_val = "1" if is_dark else "0"

    os.system(f"gsettings set org.gnome.desktop.interface color-scheme '{opp_val}'")
    os.system(f"gsettings set org.gnome.desktop.interface color-scheme '{gs_val}'")
    os.system("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'")
    os.system("gsettings set org.gnome.desktop.interface gtk-theme 'Material-Gnome'")

    os.system(
        f"sed -i 's/^gtk-theme-name=.*/gtk-theme-name=Material-Gnome/' '{home}/.config/gtk-3.0/settings.ini' '{home}/.config/gtk-4.0/settings.ini' 2>/dev/null"
    )
    os.system(
        f"sed -i 's/^Net\\/ThemeName.*/Net\\/ThemeName \"Material-Gnome\"/' '{home}/.config/xsettingsd/xsettingsd.conf' 2>/dev/null"
    )
    import configparser

    for qtct in ["qt5ct", "qt6ct"]:
        qtct_conf = os.path.join(home, ".config", qtct, f"{qtct}.conf")
        if os.path.exists(qtct_conf):
            config = configparser.ConfigParser()
            config.optionxform = str  # Preserve case
            config.read(qtct_conf)
            if "Appearance" not in config:
                config["Appearance"] = {}

            icon_theme = "Papirus-Dark" if is_dark else "Papirus-Light"
            config["Appearance"]["icon_theme"] = icon_theme

            with open(qtct_conf, "w") as configfile:
                config.write(configfile)

    os.system("killall -HUP xsettingsd 2>/dev/null || true")

    # 3. Nvim
    nvim_bg = "dark" if is_dark else "light"
    qs_colors = f"""vim.g.qs_colors = {{
  bg = "{sanitize_color(bg)}",
  bgSecondary = "{sanitize_color(bgSecondary)}",
  fg = "{sanitize_color(fg)}",
  muted = "{sanitize_color(muted)}",
  accent = "{sanitize_color(accent)}",
  accentComplementary = "{sanitize_color(accentComplementary)}"
}}
"""
    lua_content = f'vim.opt.background = "{nvim_bg}"\n{qs_colors}pcall(vim.cmd.colorscheme, "quickshell")'
    with open(os.path.join(home, ".cache", "quickshell", "nvim_theme.lua"), "w") as f:
        f.write(lua_content)

    # 4. Hyprland
    hypr_content = f"""-- Generated by Quickshell Theme service
return {{
    border = "{hypr_color(border)}",
    border_alpha = "{hypr_color(border, "aa")}",
    accent = "{hypr_color(accent)}",
    accent_alpha = "{hypr_color(accent, "ee")}"
}}
"""
    hypr_dir = os.path.join(home, ".config", "hypr")
    os.makedirs(hypr_dir, exist_ok=True)
    with open(os.path.join(hypr_dir, "colors.lua"), "w") as f:
        f.write(hypr_content)

    # 5. Starship
    starship_file = os.path.join(home, ".config", "starship", "starship.toml")
    os.makedirs(os.path.dirname(starship_file), exist_ok=True)
    if not os.path.exists(starship_file):
        open(starship_file, "a").close()

    toml = f"""# --- Quickshell Palette ---
[palettes.quickshell]
bg = "{sanitize_color(bg)}"
accent = "{sanitize_color(accent)}"
accentcomplementary = "{sanitize_color(accentComplementary)}"
"""
    os.system(f"sed -i '/# --- Quickshell Palette ---/,$d' '{starship_file}'")
    with open(starship_file, "a") as f:
        f.write(toml)

    # 6. Qt (qt5ct / qt6ct)
    def to_argb(c, alpha="ff"):
        s = sanitize_color(c)
        if len(s) == 7:
            return f"#{alpha}{s[1:]}"
        return s

    qt_colors = [
        to_argb(fg),  # 0 WindowText
        to_argb(bgSecondary),  # 1 Button
        to_argb(muted),  # 2 Light
        to_argb(muted),  # 3 Midlight
        to_argb(bgSecondary),  # 4 Dark
        to_argb(bgSecondary),  # 5 Mid
        to_argb(fg),  # 6 Text
        to_argb(fg),  # 7 BrightText
        to_argb(fg),  # 8 ButtonText
        to_argb(bg),  # 9 Base
        to_argb(bg),  # 10 Window
        to_argb(shadow),  # 11 Shadow
        to_argb(accent),  # 12 Highlight
        to_argb(bg),  # 13 HighlightedText
        to_argb(accent),  # 14 Link
        to_argb(accentComplementary),  # 15 LinkVisited
        to_argb(bgSecondary),  # 16 AlternateBase
        "#ffffffff",  # 17 NoRole
        to_argb(bgSecondary),  # 18 ToolTipBase
        to_argb(fg),  # 19 ToolTipText
        to_argb(muted, "80"),  # 20 PlaceholderText
    ]

    qt_colors_str = ", ".join(qt_colors)
    qt_conf_content = f"[ColorScheme]\nactive_colors={qt_colors_str}\ninactive_colors={qt_colors_str}\ndisabled_colors={qt_colors_str}\n"

    for qtct in ["qt5ct", "qt6ct"]:
        qt_dir = os.path.join(home, ".config", qtct, "colors")
        os.makedirs(qt_dir, exist_ok=True)
        scheme_path = os.path.join(qt_dir, "quickshell.conf")
        with open(scheme_path, "w") as f:
            f.write(qt_conf_content)

        qtct_conf = os.path.join(home, ".config", qtct, f"{qtct}.conf")
        if os.path.exists(qtct_conf):
            config = configparser.ConfigParser()
            config.optionxform = str
            config.read(qtct_conf)
            if "Appearance" not in config:
                config["Appearance"] = {}
            config["Appearance"]["color_scheme_path"] = scheme_path
            config["Appearance"]["custom_palette"] = "true"
            with open(qtct_conf, "w") as configfile:
                config.write(configfile)

    # 7. Btop
    btop_theme = f"""# Generated by Quickshell Theme service
theme[main_bg]="{sanitize_color(bg)}"
theme[main_fg]="{sanitize_color(fg)}"
theme[title]="{sanitize_color(fg)}"
theme[hi_fg]="{sanitize_color(accent)}"
theme[selected_bg]="{sanitize_color(bgSecondary)}"
theme[selected_fg]="{sanitize_color(accent)}"
theme[inactive_fg]="{sanitize_color(muted)}"
theme[graph_text]="{sanitize_color(muted)}"
theme[meter_bg]="{sanitize_color(bgSecondary)}"
theme[proc_misc]="{sanitize_color(accent)}"
theme[cpu_box]="{sanitize_color(border)}"
theme[mem_box]="{sanitize_color(border)}"
theme[net_box]="{sanitize_color(border)}"
theme[proc_box]="{sanitize_color(border)}"
theme[div_line]="{sanitize_color(border)}"
theme[temp_start]="{sanitize_color(accentComplementary)}"
theme[temp_mid]="{sanitize_color(accent)}"
theme[temp_end]="{sanitize_color(accentComplementary)}"
theme[cpu_start]="{sanitize_color(accent)}"
theme[cpu_mid]="{sanitize_color(accent)}"
theme[cpu_end]="{sanitize_color(accentComplementary)}"
theme[free_start]="{sanitize_color(accent)}"
theme[free_mid]="{sanitize_color(accent)}"
theme[free_end]="{sanitize_color(accent)}"
theme[cached_start]="{sanitize_color(muted)}"
theme[cached_mid]="{sanitize_color(muted)}"
theme[cached_end]="{sanitize_color(muted)}"
theme[available_start]="{sanitize_color(accent)}"
theme[available_mid]="{sanitize_color(accent)}"
theme[available_end]="{sanitize_color(accent)}"
theme[used_start]="{sanitize_color(accentComplementary)}"
theme[used_mid]="{sanitize_color(accentComplementary)}"
theme[used_end]="{sanitize_color(accentComplementary)}"
theme[download_start]="{sanitize_color(accent)}"
theme[download_mid]="{sanitize_color(accent)}"
theme[download_end]="{sanitize_color(accent)}"
theme[upload_start]="{sanitize_color(accentComplementary)}"
theme[upload_mid]="{sanitize_color(accentComplementary)}"
theme[upload_end]="{sanitize_color(accentComplementary)}"
"""
    btop_theme_dir = os.path.join(home, ".config", "btop", "themes")
    os.makedirs(btop_theme_dir, exist_ok=True)
    with open(os.path.join(btop_theme_dir, "quickshell.theme"), "w") as f:
        f.write(btop_theme)

    btop_conf = os.path.join(home, ".config", "btop", "btop.conf")
    if os.path.exists(btop_conf):
        os.system(
            f"sed -i 's/^color_theme = .*/color_theme = \"quickshell\"/' '{btop_conf}'"
        )

    # 8. SVGs in assets
    import re

    assets_dir = os.path.join(home, ".config", "quickshell", "assets")
    if os.path.exists(assets_dir):
        for svg_file in ["settings-icon.svg", "keybinds-icon.svg"]:
            svg_path = os.path.join(assets_dir, svg_file)
            if not os.path.exists(svg_path):
                continue
            with open(svg_path, "r") as f:
                content = f.read()

            # Reemplazar colores en los gradientes si existen
            new_content = re.sub(
                r'(<stop\s+offset="0%"\s+stop-color=")[^"]+(")',
                f"\\g<1>{sanitize_color(accent)}\\g<2>",
                content,
            )
            new_content = re.sub(
                r'(<stop\s+offset="100%"\s+stop-color=")[^"]+(")',
                f"\\g<1>{sanitize_color(accentComplementary)}\\g<2>",
                new_content,
            )

            if content != new_content:
                with open(svg_path, "w") as f:
                    f.write(new_content)


if __name__ == "__main__":
    main()

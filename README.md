<div align="center">

# Minflair

**A custom Hyprland environment for Arch Linux, built around dynamic theming and Quickshell.**

<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786064817/output_sthtxe.webp" alt="Preview" />

</div>

---

## ✨ Features

- 🎨 **Dynamic Theming** — Generate custom color schemes dynamically directly from your current wallpaper, alongside 2 default static themes.
- 🖥️ **Quickshell Integration** — GTK, Neovim, Starship, Kitty, and Hyprland have their colors generated dynamically from Quickshell, ensuring a fully unified system theme.
- 🖼️ **Wallpaper Selector** — Browse and apply wallpapers directly from a built-in widget.
- 🔒 **Lock Screen** — Custom Lock Screen built entirely in Quickshell, fully integrated with your dynamic theme.
- ⚡ **Zsh** — Configured with Starship prompt, fzf-tab, autosuggestions, syntax highlighting, and history substring search.
- 📝 **Neovim** — Full Lua config with lazy.nvim, auto-synced color scheme.

---

## 🚀 Quick Install

```bash
# Clone this repository (shallow clone to save space and time)
git clone --depth 1 https://github.com/t4lentles5/minflair.git ~/.dotfiles

# Enter the directory
cd ~/.dotfiles

# Give execution permissions to the script and run it
chmod +x install.sh
./install.sh
```

> [!IMPORTANT]
>
> - This script is exclusively designed for **Arch Linux** based distributions (it uses `pacman` natively).
> - **NOTE:** Run the script as your **normal user**. The script will ask for `sudo` permissions on its own when strictly necessary to install system packages.

---

## 🔧 Post-Installation Setup

### 1. Reboot

Once the script finishes, **reboot your computer** to ensure your new `zsh` shell, global variables, themes, and system daemons are fully loaded:

```bash
sudo reboot
```

### 2. Set your profile picture (`.face`)

The Quickshell dashboard displays your user avatar from `~/.face`. Place a **square image** (PNG or JPG, 256×256 recommended) in your home directory:

```bash
# Copy your desired profile picture
cp /path/to/your/avatar.png ~/.face
```

### 3. Set your wallpaper

Wallpapers are stored in `~/Pictures/Wallpapers/`. You can add your own wallpapers to this directory and use the wallpaper selector widget (`Ctrl + Alt + W`) to apply them.

### 4. Monitor Configuration

The default monitor config is set to auto-detect. If you need custom resolution, refresh rate, or multi-monitor setup, edit:

```bash
~/.config/hypr/monitors.lua
```

Refer to the [Hyprland Wiki — Monitors](https://wiki.hyprland.org/Configuring/Monitors/) for syntax details.

### 5. Restore from Backup

If anything goes wrong, the installer creates a timestamped backup of your previous configuration:

```
~/.dotfiles_backup/<timestamp>/
```

---

## 🖥️ Quickshell Widgets

This rice features a collection of custom widgets built with Quickshell, designed to be fast, interactive, and completely integrated with the system's dynamic styling:

- **Main Panel**: A comprehensive hub featuring 3 tabs:
  - **Dashboard**: GitHub stats (including top repo), media player, package updates, and a random quote.
  - **Performance**: Real-time monitoring for CPU, RAM, VRAM, and Disk usage.
  - **Activity**: Daily screen time tracking and your top 5 most used applications.
    <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786064956/output_rzqhid.webp" alt="Main Panel Widget" />

- **Settings App**: A dedicated graphical interface to configure your rice, credentials, and preferences effortlessly without manually editing files.
  <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786065403/Shot-2026-08-06-201609_biioiv.png" alt="Settings App" />

- **Lock Screen**: A fully functional custom lock screen built entirely in Quickshell, fully integrated with your dynamic theme.
  <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786065276/Shot-2026-08-06-201413_s6pdnd.png" alt="Lock Screen Widget" />

- **Keybinds Cheat Sheet**: A built-in, searchable overlay that displays all your configured shortcuts directly on your desktop.
  <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786065694/Shot-2026-08-06-202115_thcy6l.png" alt="Keybinds Cheat Sheet Widget" />

- **Wallpaper Selector**: An interactive grid browser that lets you preview and apply wallpapers from `~/Pictures/Wallpapers/` on the fly.
  <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786065056/Shot-2026-08-06-201025_snexor.png" alt="Wallpaper Selector Widget" />

- **Sidebar**: A unified control center featuring quick settings, performance modes and desktop notifications.
  <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786065349/Shot-2026-08-06-201526_s0kvt6.png" alt="Sidebar Widget" />

- **Application Launcher**: A clean, keyboard-navigable menu to search and run applications.
  <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786065112/Shot-2026-08-06-201135_taednb.png" alt="Application Launcher Widget" />

- **Package Manager**: A graphical utility to search, install, update, and remove official Arch Linux and AUR packages easily.
  <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786065503/Shot-2026-08-06-201806_urpbrj.png" alt="Package Manager Widget" />

- **Clipboard History**: A handy widget to browse and paste from your clipboard history.
  <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786065192/Shot-2026-08-06-201251_dch65w.png" alt="Clipboard History Widget" />

- **Screen Capture**: A dedicated tool for taking screenshots and recording your screen.
  <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786065442/Shot-2026-08-06-201705_shhppn.png" alt="Screen Capture Widget" />

- **Power Menu**: A sleek menu for session management (shutdown, reboot, suspend, lock, logout).
  <img src="https://res.cloudinary.com/diu2godjy/image/upload/v1786065544/Shot-2026-08-06-201847_mu6ewf.png" alt="Power Menu Widget" />

## ⌨️ Keybinds

> [!NOTE]  
> You don't need to memorize these! Press `SUPER + K` at any time to open the built-in **Keybinds Cheat Sheet** directly on your desktop!

## ❓ Troubleshooting

<details>
<summary><b>Quickshell dashboard shows a generic avatar</b></summary>

Place a square image at `~/.face` (PNG or JPG). The dashboard reads it from `$HOME/.face`. SDDM also uses this file for the login screen.

```bash
cp /path/to/avatar.png ~/.face
```

</details>

<details>
<summary><b>No wallpapers appear in the wallpaper selector</b></summary>

You must manually place your own wallpapers in the `~/Pictures/Wallpapers/` directory. Create this directory if it doesn't exist and add your images there.

</details>

<details>
<summary><b>GTK apps don't follow the theme change</b></summary>

Nautilus is automatically restarted when switching between light ↔ dark mode. For other GTK apps, you may need to close and reopen them. The `nwg-look` tool is used during installation to apply the initial GTK settings.

</details>

<details>
<summary><b>Notifications aren't showing</b></summary>

The installer disables `dunst` because Quickshell handles notifications natively. If you installed another notification daemon, it may conflict. Check with:

```bash
systemctl --user status dunst.service
```

</details>

<details>
<summary><b>Installation errors or packages failed to install</b></summary>

The installer automatically captures all warnings and errors in a log file. You can check it to find out exactly what went wrong:

```bash
cat ~/install_errors.log
```

If packages failed to install, ensure your mirrors are up to date (`sudo pacman -Syy`) and that your AUR helper is working correctly (`yay -Syu`).

</details>

## 📜 License and Credits

This project is licensed under the [GNU General Public License v3.0](LICENSE).

### Third-Party Assets

- **Tabler Icons**: Licensed under the [MIT License](https://github.com/tabler/tabler-icons/blob/master/LICENSE).
- **Material Symbols (Google Fonts)**: Licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
- **Material GNOME Theme**: Licensed under the [GNU General Public License v3.0](https://github.com/SakibShahariar/material-gnome-theme/blob/main/LICENSE).
- **Simple Icons**: Licensed under the [CC0 1.0 Universal License](https://creativecommons.org/publicdomain/zero/1.0/).

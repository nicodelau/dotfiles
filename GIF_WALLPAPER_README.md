# GIF Wallpaper Support - README

## Overview
Your dotfiles now support animated GIF wallpapers with `awww`! This includes optimized performance settings for smooth animation.

## Features
✅ **Full GIF Support** - All wallpaper scripts now detect and handle GIFs
✅ **Performance Optimized** - Different settings for static vs animated wallpapers  
✅ **Seamless Integration** - Works with existing wallpaper selector and keybinds
✅ **Auto-Detection** - Scripts automatically detect GIF files and optimize accordingly

## File Extensions Supported
- `.jpg`, `.jpeg` - JPEG images
- `.png` - PNG images  
- `.webp` - WebP images
- `.gif` - **Animated GIF images** ⭐

## Scripts Updated
1. **wallpaper-selector.sh** - Now includes GIF support with optimized transitions
2. **wallpaper-selector.lua** - Enhanced with GIF detection and performance settings
3. **restore-wallpaper.sh** - Can restore GIF wallpapers on startup
4. **set-gif-wallpaper.sh** - **NEW** dedicated script for GIF wallpapers

## Usage

### Setting GIF Wallpapers
```bash
# Via wallpaper selector (recommended)
~/.config/hypr/scripts/wallpaper-selector.sh

# Directly set a GIF (optimized)
~/.config/hypr/scripts/set-gif-wallpaper.sh "path/to/animation.gif"

# Manual awww command
awww img "path/to/animation.gif" --transition-type simple --filter Nearest
```

### Performance Settings

**For GIFs (Optimized):**
- `--transition-type simple` - Instant transition, no animation overhead
- `--transition-step 255` - Immediate switch
- `--filter Nearest` - Fastest scaling filter
- No transition duration/fps settings

**For Static Images (Enhanced):**
- `--transition-type grow` - Smooth growing circle transition
- `--transition-pos center` - Animation from center
- `--transition-duration 1` - 1-second transition
- `--transition-fps 60` - Smooth 60fps transition

## Performance Tips

1. **GIF Size**: Smaller GIFs (1080p vs 4K) use less CPU/memory
2. **Frame Rate**: Lower FPS GIFs are more efficient
3. **File Size**: Compress GIFs when possible without losing quality
4. **Multiple Monitors**: GIFs are mirrored across all displays

## File Locations

```
~/Pictures/wallpapers/          # Your wallpaper directory (includes GIFs)
~/.config/hypr/scripts/         # Wallpaper management scripts
~/.cache/current_wallpaper      # Currently set wallpaper path
~/.cache/wallpaper-thumbs/      # Generated thumbnails for selector
```

## Keybinds
Your existing wallpaper keybinds will work with GIFs:
- Use your configured wallpaper selector hotkey
- GIFs will be automatically detected and optimized

## Troubleshooting

**GIF not animating?**
- Ensure `awww-daemon` is running: `killall -q awww-daemon; awww-daemon &`
- Check if the GIF is valid: `file path/to/animation.gif`

**Performance issues?**
- Use the dedicated GIF script: `set-gif-wallpaper.sh`
- Reduce GIF resolution or frame rate
- Consider using WebP animated format as alternative

**Wallpaper not persisting?**
- Check if `~/.cache/current_wallpaper` contains the correct path
- Ensure restore script runs on startup via `hypr/autostart.conf`

## Advanced awww GIF Options

```bash
# Different transition effects for GIFs
awww img animation.gif --transition-type fade --transition-duration 2

# Custom resize modes
awww img animation.gif --resize fit     # Maintain aspect ratio
awww img animation.gif --resize crop    # Fill screen (default)
awww img animation.gif --resize stretch # Stretch to fit

# Multi-monitor specific display
awww img animation.gif --outputs "DP-1,HDMI-A-1"
```

Enjoy your animated wallpapers! 🎨✨
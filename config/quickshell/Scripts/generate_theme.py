#!/usr/bin/env python3
import json
import os
import subprocess
import sys


def rgb_to_hsl(r, g, b):
    r_pct = r / 255.0
    g_pct = g / 255.0
    b_pct = b / 255.0
    max_c = max(r_pct, g_pct, b_pct)
    min_c = min(r_pct, g_pct, b_pct)
    l = (max_c + min_c) / 2.0
    if max_c == min_c:
        h = s = 0.0
    else:
        d = max_c - min_c
        s = d / (2.0 - max_c - min_c) if l > 0.5 else d / (max_c + min_c)
        if max_c == r_pct:
            h = (g_pct - b_pct) / d + (6.0 if g_pct < b_pct else 0.0)
        elif max_c == g_pct:
            h = (b_pct - r_pct) / d + 2.0
        else:
            h = (r_pct - g_pct) / d + 4.0
        h /= 6.0
    return h * 360.0, s, l


def hue_distance(h1, h2):
    d = abs(h1 - h2) % 360
    return 360 - d if d > 180 else d


def clamp_rgb(val):
    return max(0, min(255, int(val)))


def to_hex(r, g, b):
    return f"#{r:02x}{g:02x}{b:02x}"


def force_hsl(h, s, l, target_s, target_l):
    s = max(target_s, s)
    c = (1.0 - abs(2.0 * target_l - 1.0)) * s
    x = c * (1.0 - abs((h / 60.0) % 2.0 - 1.0))
    m = target_l - c / 2.0
    if 0 <= h < 60:
        r, g, b = c, x, 0
    elif 60 <= h < 120:
        r, g, b = x, c, 0
    elif 120 <= h < 180:
        r, g, b = 0, c, x
    elif 180 <= h < 240:
        r, g, b = 0, x, c
    elif 240 <= h < 300:
        r, g, b = x, 0, c
    else:
        r, g, b = c, 0, x
    return to_hex(
        clamp_rgb((r + m) * 255), clamp_rgb((g + m) * 255), clamp_rgb((b + m) * 255)
    )


def get_chroma(color_obj):
    return (
        max(color_obj["r"], color_obj["g"], color_obj["b"])
        - min(color_obj["r"], color_obj["g"], color_obj["b"])
    ) / 255.0


def color_distance(c1, c2):
    r1, g1, b1 = int(c1[1:3], 16), int(c1[3:5], 16), int(c1[5:7], 16)
    r2, g2, b2 = int(c2[1:3], 16), int(c2[3:5], 16), int(c2[5:7], 16)
    return (r1 - r2) ** 2 + (g1 - g2) ** 2 + (b1 - b2) ** 2


def main():
    if len(sys.argv) < 2:
        print("Usage: generate_theme.py <image_path>")
        sys.exit(1)

    image_path = sys.argv[1]
    if not os.path.exists(image_path):
        print(f"Error: image not found: {image_path}")
        sys.exit(1)

    processing_path = image_path
    magick_path = image_path

    ext = os.path.splitext(image_path)[1].lower()
    if ext in [".gif", ".webp"]:
        # Cache the extracted frame persistently in ~/.cache/quickshell/frames/
        # so subsequent runs with the same wallpaper skip extraction entirely.
        home = os.path.expanduser("~")
        frames_dir = os.path.join(home, ".cache", "quickshell", "frames")
        os.makedirs(frames_dir, exist_ok=True)
        base_name = os.path.basename(image_path)
        cached_frame = os.path.join(frames_dir, base_name + ".jpg")

        # Only re-extract if the cache doesn't exist or is older than the source
        need_extract = True
        if os.path.exists(cached_frame):
            src_mtime = os.path.getmtime(image_path)
            cache_mtime = os.path.getmtime(cached_frame)
            if cache_mtime >= src_mtime:
                need_extract = False

        if need_extract:
            try:
                # Use GdkPixbuf to load only the first frame of the animation.
                # Unlike magick[0] which decompresses ALL frames (10GB+ RAM),
                # GdkPixbuf loads just the first frame natively and efficiently.
                # ffmpeg also doesn't work — it can't decode animated WebP at all.
                import gi

                gi.require_version("GdkPixbuf", "2.0")
                from gi.repository import GdkPixbuf

                pixbuf = GdkPixbuf.Pixbuf.new_from_file(image_path)

                # Flatten alpha onto black background (matches static image processing)
                if pixbuf.get_has_alpha():
                    bg = GdkPixbuf.Pixbuf.new(
                        GdkPixbuf.Colorspace.RGB,
                        False,
                        8,
                        pixbuf.get_width(),
                        pixbuf.get_height(),
                    )
                    bg.fill(0x000000FF)
                    pixbuf.composite(
                        bg,
                        0,
                        0,
                        pixbuf.get_width(),
                        pixbuf.get_height(),
                        0,
                        0,
                        1.0,
                        1.0,
                        GdkPixbuf.InterpType.BILINEAR,
                        255,
                    )
                    pixbuf = bg

                pixbuf.savev(cached_frame, "jpeg", ["quality"], ["90"])
            except Exception as e:
                print("Warning: GdkPixbuf frame extraction failed:", e)
                cached_frame = None

        if cached_frame and os.path.exists(cached_frame):
            processing_path = cached_frame
            magick_path = cached_frame
        else:
            print(
                "Warning: no cached frame available, using original file (may use high RAM)."
            )
            processing_path = image_path
            magick_path = image_path

    # 1. Determine if the wallpaper is dark or light using ImageMagick mean brightness
    try:
        cmd_mean = [
            "magick",
            magick_path,
            "-background",
            "black",
            "-alpha",
            "remove",
            "-colorspace",
            "gray",
            "-format",
            "%[fx:mean]",
            "info:",
        ]
        res_mean = subprocess.run(
            cmd_mean,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True,
        )
        out_clean = res_mean.stdout.strip()
        val = out_clean.split()[0] if out_clean else "0.2"
        import re

        match = re.search(r"[0-9\.]+", val)
        if match:
            brightness = float(match.group(0))
        else:
            brightness = 0.2
    except Exception as e:
        print("Error getting image mean, falling back to dark:", e)
        brightness = 0.2

    is_dark = brightness <= 0.4
    palette = "dark" if is_dark else "light"

    # 2. Extract colors from ImageMagick histogram to get a rich sample and pixel counts
    import re

    histogram_colors = {}
    try:
        cmd_magick = [
            "magick",
            magick_path,
            "-background",
            "black",
            "-alpha",
            "remove",
            "-resize",
            "100x100",
            "-colors",
            "32",
            "-format",
            "%c",
            "histogram:info:",
        ]
        res_magick = subprocess.run(
            cmd_magick,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True,
        )
        for line in res_magick.stdout.splitlines():
            m = re.search(r"(\d+):\s*\(.*?\)\s*(#[0-9a-fA-F]{6})", line)
            if m:
                count = int(m.group(1))
                hex_c = m.group(2).lower()
                histogram_colors[hex_c] = histogram_colors.get(hex_c, 0) + count
    except Exception as e:
        print("Warning: failed to extract colors from ImageMagick histogram:", e)

    # 3. Sort histogram colors by frequency
    sorted_hist = sorted(histogram_colors.items(), key=lambda x: x[1], reverse=True)
    unique_hex = [c[0] for c in sorted_hist]

    # Convert all to HSL and assign pixel counts
    color_objs = []
    for hex_c in unique_hex:
        r = int(hex_c[1:3], 16)
        g = int(hex_c[3:5], 16)
        b = int(hex_c[5:7], 16)
        h, s, l = rgb_to_hsl(r, g, b)

        pixels = histogram_colors[hex_c]

        color_objs.append(
            {
                "hex": hex_c,
                "r": r,
                "g": g,
                "b": b,
                "h": h,
                "s": s,
                "l": l,
                "pixels": pixels,
            }
        )

    if not color_objs:
        print("Error: ImageMagick returned no colors.")
        sys.exit(1)

    # Base colors
    bg_color = color_objs[0]

    # Calculate image colorfulness directly from the raw ImageMagick histogram
    # to avoid Wallust's forced ANSI colors skewing the result.
    total_colorful_px = 0
    total_px = 0

    # This ignores deep shadows (L < 0.20) which often contain WebP/JPEG compression artifacts (like fake red).
    # We also ignore pixels with >15% chroma (too saturated for a grayscale image) and noise (<0.5% of pixels).
    best_tint_hue = 0.0
    max_tint_chroma = -1.0

    total_px_count = sum(histogram_colors.values())

    for hex_c, count in histogram_colors.items():
        hr, hg, hb = int(hex_c[1:3], 16), int(hex_c[3:5], 16), int(hex_c[5:7], 16)
        h, s, l = rgb_to_hsl(hr, hg, hb)
        hchroma = (max(hr, hg, hb) - min(hr, hg, hb)) / 255.0

        if (
            l > 0.20
            and l < 0.90
            and hchroma < 0.15
            and (count / total_px_count) > 0.005
        ):
            if hchroma > max_tint_chroma:
                max_tint_chroma = hchroma
                best_tint_hue = h

        if hchroma >= 0.08:
            total_colorful_px += count
        total_px += count

    colorful_ratio = total_colorful_px / total_px if total_px > 0 else 0.0
    is_grayscale_image = colorful_ratio < 0.05

    # Find most frequent colorful candidate
    colorful_candidates = [c for c in color_objs if get_chroma(c) >= 0.08]
    if is_grayscale_image:
        dominant_cand = None
        dominant_hue = best_tint_hue
        dominant_sat = 0.15
    elif colorful_candidates:
        dominant_cand = max(colorful_candidates, key=lambda c: c["pixels"])
        dominant_hue = dominant_cand["h"]
        dominant_sat = dominant_cand["s"]
    else:
        dominant_cand = None
        dominant_hue = true_dom_h
        dominant_sat = 0.15

    # Generate background, foreground, and muted colors based on wallpaper
    bg_s = max(0.10, min(0.20, dominant_sat * 0.5))
    bg_val = force_hsl(
        dominant_hue, bg_s, bg_color["l"], bg_s, 0.09 if is_dark else 0.92
    )

    # Monochromatic generation: ONLY use the top 10 most frequent colors to avoid missing small accents
    sorted_by_pixels = sorted(color_objs, key=lambda c: c["pixels"], reverse=True)
    top_colors = sorted_by_pixels[:10]

    colorful_top = [c for c in top_colors if get_chroma(c) >= 0.08]
    if colorful_top and not is_grayscale_image:
        primary_accent = max(colorful_top, key=get_chroma)
    else:
        primary_accent = top_colors[0]

    is_grayscale_theme = (get_chroma(primary_accent) < 0.08) or is_grayscale_image

    if is_grayscale_theme:
        if max_tint_chroma > 0.01:
            # The grayscale image has a subtle tint (e.g. cyan glow). Amplify it!
            accent_color = force_hsl(
                dominant_hue, 0.40, 0.0, 0.40, 0.80 if is_dark else 0.40
            )
        else:
            # The image is purely black and white. Use pure grey/white.
            accent_color = force_hsl(0, 0.0, 0.0, 0.0, 0.95 if is_dark else 0.05)
    else:
        accent_color = force_hsl(
            primary_accent["h"],
            primary_accent["s"],
            primary_accent["l"],
            0.50,
            0.60 if is_dark else 0.45,
        )

    # Text colors slightly tinted with the wallpaper hue for better integration
    fg_val = force_hsl(dominant_hue, bg_s, 0.5, bg_s * 0.3, 0.92 if is_dark else 0.12)

    h_acc, s_acc, l_acc = rgb_to_hsl(
        int(accent_color[1:3], 16),
        int(accent_color[3:5], 16),
        int(accent_color[5:7], 16),
    )
    # Using a 45 degree hue shift for gradients as true complementary (+180) creates muddy middle colors
    accent_complementary = force_hsl((h_acc + 45) % 360, s_acc, l_acc, s_acc, l_acc)

    generated = {
        "bg": bg_val,
        "fg": fg_val,
        "accent": accent_color,
        "accentComplementary": accent_complementary,
    }

    # Save to quickshell cache
    home = os.path.expanduser("~")
    cache_dir = os.path.join(home, ".cache", "quickshell")
    os.makedirs(cache_dir, exist_ok=True)

    # Always save to wallpaper_colorscheme.json
    wallpaper_generated = dict(generated)
    wallpaper_generated["name"] = "Wallpaper Theme"
    wallpaper_generated["generateFromWallpaper"] = True

    wallpaper_file = os.path.join(cache_dir, "wallpaper_colorscheme.json")
    with open(wallpaper_file, "w") as f:
        json.dump(wallpaper_generated, f, indent=2)

    # Check if we should overwrite the active colorscheme.json
    active_file = os.path.join(cache_dir, "colorscheme.json")
    should_write_active = True
    if len(sys.argv) >= 3:
        should_write_active = sys.argv[2].lower() in ["true", "1", "yes"]
    else:
        if os.path.exists(active_file):
            try:
                with open(active_file, "r") as f:
                    curr_data = json.load(f)
                    should_write_active = curr_data.get("generateFromWallpaper", False)
            except Exception:
                pass

    if should_write_active:
        with open(active_file, "w") as f:
            json.dump(wallpaper_generated, f, indent=2)
        print(
            f"Success: Generated {'dark' if is_dark else 'light'} colorscheme.json and wallpaper_colorscheme.json"
        )
    else:
        print(
            f"Success: Generated {'dark' if is_dark else 'light'} wallpaper_colorscheme.json (active colorscheme preserved)"
        )

    # Always emit colors to stdout so QML can apply them immediately without a second cat
    print("COLORS:" + json.dumps(wallpaper_generated))


if __name__ == "__main__":
    main()

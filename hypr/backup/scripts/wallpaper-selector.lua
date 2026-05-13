#!/usr/bin/env lua
-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃           Wallpaper Selector with Preview (rofi)            ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

local wallpaper_dir = os.getenv("HOME") .. "/Pictures/wallpapers"
local cache_dir = os.getenv("HOME") .. "/.cache/wallpaper-thumbs"

-- Create cache directory
os.execute("mkdir -p " .. cache_dir)

-- Get list of image files
local function get_wallpapers()
    local wallpapers = {}
    local handle = io.popen('find -L "' .. wallpaper_dir .. '" -type f \\( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \\) 2>/dev/null | sort')
    if handle then
        for line in handle:lines() do
            table.insert(wallpapers, line)
        end
        handle:close()
    end
    return wallpapers
end

-- Generate thumbnail for rofi
local function get_thumbnail(path)
    local filename = path:match("([^/]+)$")
    local thumb_path = cache_dir .. "/" .. filename:gsub("%.", "_thumb.")

    -- Check if thumbnail exists
    local f = io.open(thumb_path, "r")
    if f then
        f:close()
    else
        -- Create thumbnail using ImageMagick
        os.execute(string.format(
            'convert "%s" -resize 200x120^ -gravity center -extent 200x120 "%s" 2>/dev/null',
            path, thumb_path
        ))
    end

    return thumb_path
end

-- Build rofi input with icons
local function build_rofi_input(wallpapers)
    local lines = {}
    for _, path in ipairs(wallpapers) do
        local name = path:match("([^/]+)$"):gsub("%.[^.]+$", "")
        local thumb = get_thumbnail(path)
        -- rofi icon format: name\0icon\x1fpath
        table.insert(lines, string.format("%s\x00icon\x1f%s\x1finfo\x1f%s", name, thumb, path))
    end
    return table.concat(lines, "\n")
end

-- Set wallpaper using awww
local function set_wallpaper(path)
    -- Check if it's a GIF for optimized handling
    local is_gif = path:lower():match("%.gif$")
    
    if is_gif then
        -- GIF: Use simpler transition for better performance
        os.execute(string.format(
            'awww img "%s" --transition-type simple --transition-step 255 --filter Nearest',
            path
        ))
        -- Notify with animated wallpaper message
        os.execute(string.format(
            'notify-send "Animated Wallpaper" "Set to %s" -i preferences-desktop-wallpaper',
            path:match("([^/]+)$")
        ))
    else
        -- Static image: Use fancy transition
        os.execute(string.format(
            'awww img "%s" --transition-type grow --transition-pos center --transition-duration 1 --transition-fps 60',
            path
        ))
        -- Standard notification
        os.execute(string.format(
            'notify-send "Wallpaper" "Changed to %s" -i preferences-desktop-wallpaper',
            path:match("([^/]+)$")
        ))
    end

    -- Save current wallpaper path for persistence
    local f = io.open(os.getenv("HOME") .. "/.cache/current_wallpaper", "w")
    if f then
        f:write(path)
        f:close()
    end
end

-- Main
local wallpapers = get_wallpapers()

if #wallpapers == 0 then
    os.execute('notify-send "Wallpaper Selector" "No wallpapers found in ' .. wallpaper_dir .. '" -i dialog-warning')
    os.exit(1)
end

-- Show rofi selector
local rofi_input = build_rofi_input(wallpapers)
local rofi_cmd = string.format(
    'echo -e "%s" | rofi -dmenu -i -show-icons -theme ~/.config/rofi/wallpaper.rasi -p "Wallpaper" -format "i"',
    rofi_input:gsub('"', '\\"'):gsub('\n', '\\n')
)

local handle = io.popen(rofi_cmd)
if handle then
    local result = handle:read("*a"):gsub("%s+$", "")
    handle:close()

    local index = tonumber(result)
    if index and wallpapers[index + 1] then
        set_wallpaper(wallpapers[index + 1])
    end
end

#!/usr/bin/env lua
-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃           EWW Widget Toggle Script                          ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

local widget = arg[1]

if not widget then
    print("Usage: eww-toggle.lua <widget-name>")
    print("Available widgets: clock, powermenu, media")
    os.exit(1)
end

-- Check if widget is open
local function is_open(name)
    local handle = io.popen("eww active-windows 2>/dev/null")
    if not handle then return false end
    local result = handle:read("*a")
    handle:close()
    return result:find(name) ~= nil
end

-- Toggle widget
local function toggle(name)
    if is_open(name) then
        os.execute("eww close " .. name)
    else
        -- Close other popups first (except workspace which is always visible)
        local popups = {"clock", "powermenu", "media"}
        for _, popup in ipairs(popups) do
            if popup ~= name and is_open(popup) then
                os.execute("eww close " .. popup)
            end
        end
        os.execute("eww open " .. name)
    end
end

-- Handle OSD with auto-close
local function show_osd(name, duration)
    duration = duration or 2
    os.execute("eww open " .. name)
    os.execute(string.format("(sleep %d && eww close %s) &", duration, name))
end

if widget == "osd-volume" or widget == "osd-brightness" then
    show_osd(widget, 2)
else
    toggle(widget)
end

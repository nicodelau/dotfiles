#!/usr/bin/env lua
-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃           Workspace Monitor for Hyprland + EWW              ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

local mode = arg[1] or "listen"

-- Get current workspace
local function get_current_workspace()
    local handle = io.popen("hyprctl activeworkspace -j 2>/dev/null")
    if not handle then return "1" end
    local result = handle:read("*a")
    handle:close()

    -- Simple JSON parsing for id field
    local id = result:match('"id"%s*:%s*(%d+)')
    return id or "1"
end

-- Get list of active workspaces
local function get_active_workspaces()
    local handle = io.popen("hyprctl workspaces -j 2>/dev/null")
    if not handle then return "1" end
    local result = handle:read("*a")
    handle:close()

    local workspaces = {}
    for id in result:gmatch('"id"%s*:%s*(%d+)') do
        table.insert(workspaces, id)
    end

    table.sort(workspaces, function(a, b) return tonumber(a) < tonumber(b) end)
    return table.concat(workspaces, ",")
end

if mode == "listen" then
    -- Listen for workspace changes using socat
    print(get_current_workspace())
    io.stdout:flush()

    local socket = os.getenv("XDG_RUNTIME_DIR") .. "/hypr/" ..
                   os.getenv("HYPRLAND_INSTANCE_SIGNATURE") .. "/.socket2.sock"

    local handle = io.popen("socat -u UNIX-CONNECT:" .. socket .. " - 2>/dev/null")
    if handle then
        for line in handle:lines() do
            if line:match("^workspace>>") or line:match("^focusedmon>>") then
                print(get_current_workspace())
                io.stdout:flush()
            end
        end
        handle:close()
    end
elseif mode == "active" then
    print(get_active_workspaces())
elseif mode == "current" then
    print(get_current_workspace())
end

local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()

-- =========================================================
-- 1. SOLUCIONES TÉCNICAS
-- =========================================================
config.front_end = "Software"
config.enable_wayland = false

-- =========================================================
-- 2. APARIENCIA
-- =========================================================
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.color_scheme = "Tokyo Night"

config.window_close_confirmation = "NeverPrompt"
config.skip_close_confirmation_for_processes_named = {
	"bash",
	"sh",
	"zsh",
	"fish",
	"tmux",
	"nu",
	"cmd.exe",
	"pwsh",
	"powershell",
	"nvim",
	"vim",
	"lazygit",
	"claude",
	"opencode",
	"gemini",
}

-- =========================================================
-- 3. AUTOMATIZACIÓN DE INICIO (LIMPIO)
-- =========================================================
wezterm.on("gui-startup", function(cmd)
	local tab1, pane1, window = mux.spawn_window(cmd or {})
	tab1:set_title("Go")

	local tab2, pane2, window2 = window:spawn_tab({})
	tab2:set_title("Next")

	local tab3, pane3, window3 = window:spawn_tab({})
	tab3:set_title("Nvim")

	local tab4, pane4, window4 = window:spawn_tab({})
	tab4:set_title("Git")
	pane4:send_text("lazygit\r")

	-- YA NO CREAMOS LA PESTAÑA IA AL INICIO
	-- Se crearán solo cuando uses los comandos.

	tab1:activate()
	window:gui_window():maximize()
end)

-- =========================================================
-- 4. FUNCIÓN INTELIGENTE: ABRIR O BUSCAR IA
-- =========================================================
local function open_ai_tab(ai_name, command)
	return wezterm.action_callback(function(window, pane)
		local current_dir = pane:get_current_working_dir()
		local path = current_dir and current_dir.file_path or wezterm.home_dir

		local mux_window = window:mux_window()

		-- 1. Buscar si ya existe una pestaña con ese nombre (ej: "Claude")
		for _, item in ipairs(mux_window:tabs_with_info()) do
			if item.tab:get_title() == ai_name then
				item.tab:activate()
				-- Si existe, detenemos lo anterior (Ctrl+C), cambiamos al dir nuevo y corremos de nuevo
				local full_cmd = string.format("\x03 cd '%s' && clear && %s\r", path, command)
				item.tab:active_pane():send_text(full_cmd)
				return
			end
		end

		-- 2. Si no existe, creamos una pestaña NUEVA
		local new_tab, new_pane, _ = mux_window:spawn_tab({})
		new_tab:set_title(ai_name) -- Le ponemos el nombre (ej: "Claude")

		-- Ejecutamos el comando en el directorio correcto
		local full_cmd = string.format("cd '%s' && clear && %s\r", path, command)
		new_pane:send_text(full_cmd)
	end)
end

-- =========================================================
-- 5. ATAJOS Y KEY TABLES
-- =========================================================
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- ACTIVAR EL MENÚ DE IA (Ctrl+b i ...)
	{
		mods = "LEADER",
		key = "i",
		action = act.ActivateKeyTable({
			name = "ia_mode",
			one_shot = true,
			timeout_milliseconds = 1000,
		}),
	},

	-- COMANDOS MÁGICOS (v: Nvim, g: Git)
	{
		mods = "LEADER",
		key = "v",
		action = wezterm.action_callback(function(window, pane)
			local current_dir = pane:get_current_working_dir()
			local path = current_dir and current_dir.file_path or wezterm.home_dir
			local mux_window = window:mux_window()
			for _, item in ipairs(mux_window:tabs_with_info()) do
				if item.tab:get_title() == "Nvim" then
					item.tab:activate()
					local cmd = string.format("cd '%s' && nvim .\r", path)
					item.tab:active_pane():send_text(cmd)
					return
				end
			end
		end),
	},
	{
		mods = "LEADER",
		key = "g", -- Para LazyGit
		action = wezterm.action_callback(function(window, pane)
			local current_dir = pane:get_current_working_dir()
			local path = current_dir and current_dir.file_path or wezterm.home_dir
			local mux_window = window:mux_window()
			for _, item in ipairs(mux_window:tabs_with_info()) do
				if item.tab:get_title() == "Git" then
					item.tab:activate()
					local cmd = string.format("q\rcd '%s' && lazygit\r", path)
					item.tab:active_pane():send_text(cmd)
					return
				end
			end
		end),
	},

	-- RESTO DE ATAJOS
	{ mods = "LEADER", key = "c", action = act.SpawnCommandInNewTab({ cwd = wezterm.home_dir }) },
	{ mods = "LEADER|SHIFT", key = '"', action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ mods = "LEADER|SHIFT", key = "%", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ mods = "LEADER", key = "z", action = act.TogglePaneZoomState },
	{ mods = "LEADER", key = "x", action = act.CloseCurrentPane({ confirm = false }) },
	{ mods = "LEADER", key = "h", action = act.ActivatePaneDirection("Left") },
	{ mods = "LEADER", key = "l", action = act.ActivatePaneDirection("Right") },
	{ mods = "LEADER", key = "k", action = act.ActivatePaneDirection("Up") },
	{ mods = "LEADER", key = "j", action = act.ActivatePaneDirection("Down") },
	{ mods = "LEADER", key = "n", action = act.ActivateTabRelative(1) },
	{ mods = "LEADER", key = "p", action = act.ActivateTabRelative(-1) },
	{ mods = "LEADER", key = "&", action = act.CloseCurrentTab({ confirm = false }) },

	-- Accesos directos numéricos
	{ mods = "LEADER", key = "1", action = act.ActivateTab(0) },
	{ mods = "LEADER", key = "2", action = act.ActivateTab(1) },
	{ mods = "LEADER", key = "3", action = act.ActivateTab(2) },
	{ mods = "LEADER", key = "4", action = act.ActivateTab(3) },
	{ mods = "LEADER", key = "5", action = act.ActivateTab(4) },
	{ mods = "LEADER", key = "6", action = act.ActivateTab(5) },

	{ mods = "LEADER", key = "w", action = act.ShowTabNavigator },
	{
		mods = "LEADER",
		key = ",",
		action = act.PromptInputLine({
			description = "Renombrar pestaña:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{ mods = "LEADER", key = "[", action = act.ActivateCopyMode },
}

-- =========================================================
-- 6. MENÚ DE IAs
-- =========================================================
config.key_tables = {
	ia_mode = {
		-- c -> Abre pestaña "Claude"
		{ key = "c", action = open_ai_tab("Claude", "claude") },

		-- o -> Abre pestaña "Opencode"
		{ key = "o", action = open_ai_tab("Opencode", "opencode") },

		-- g -> Abre pestaña "Gemini"
		{ key = "g", action = open_ai_tab("Gemini", "gemini") },

		{ key = "Escape", action = "PopKeyTable" },
	},
}

return config

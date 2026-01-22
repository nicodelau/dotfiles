local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Intenta una de estas dos opciones si la ventana no aparece:
config.front_end = "WebGpu" -- O prueba con "Software" si sigue fallando
config.enable_wayland = false -- Solo si estás en Linux y tienes problemas con Wayland

return config

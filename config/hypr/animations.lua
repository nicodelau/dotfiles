hl.config({
	animations = {
		enabled = true,
	},
})

-- Define curves
hl.curve("easeOut", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })
hl.curve("snappy", { type = "bezier", points = { { 0.2, 0.9 }, { 0.3, 1 } } })
hl.curve("gentle", { type = "bezier", points = { { 0.4, 0 }, { 0, 1 } } })
hl.curve("glass", { type = "bezier", points = { { 0.2, 0.8 }, { 0.2, 1 } } })

-- Define animations
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "glass", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "glass", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "easeOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3, bezier = "gentle" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "easeOut" })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 50, bezier = "smooth", style = "loop" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "glass", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "glass", style = "slidevert" })
hl.animation({ leaf = "layers", enabled = true, speed = 5, bezier = "glass", style = "popin 80%" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "glass", style = "popin 80%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "easeOut", style = "popin 80%" })

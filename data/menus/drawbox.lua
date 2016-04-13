local corner1 = sol.surface.create("menus/corner1.png")
local corner2 = sol.surface.create("menus/corner2.png")
local corner3 = sol.surface.create("menus/corner3.png")
local corner4 = sol.surface.create("menus/corner4.png")
local top = sol.surface.create("menus/top.png")

local function drawbox(surface, w, h)
	surface:fill_color({19,19,19})
	surface:fill_color({36,30,21}, 2, 2, w-4, w-4)
end

local function drawcorners(surface, w, h)
	local cw, ch = corner1:get_size()
	corner1:draw(surface, 0, 0)
	corner2:draw(surface, w-cw, 0)
	corner3:draw(surface, w-cw, h-ch)
	corner4:draw(surface, 0, h-ch)
end

local function drawtop(surface, w, h)
	local tw, th = top:get_size()
	top:draw(surface, (w-tw) / 2, 0)
end

local function createbox(w, h, corners, top)
	local surface = sol.surface.create(w, h)
	drawbox(surface, w, h)
	if corners then
		drawcorners(surface, w, h)
	end
	if top then
		drawtop(surface, w, h)
	end
	return surface
end

return createbox
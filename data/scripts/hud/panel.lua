local panel = {}

local entitydata = require "enemies/entitydata"


function panel:new(game)

  	local object = {}
  	setmetatable(object, self)
  	self.__index = self

  	object:initialize(game)

  	return object
end

function panel:initialize(game)

  	self.game = game
  	self.surface = sol.surface.create(75, 75)
  	self.dst_x = 0
  	self.dst_y = 0
	self.stage = 0
  	self.brown_panel_img = sol.surface.create("hud/panel_brown.png")
end

function panel:on_started()
	self.danger_sound_timer = nil
  	self:check(nil)
  	self:rebuild_surface()

end

--  check heart data and fix periodically
function panel:check()
	self:rebuild_surface()
  	-- check again in 50ms
  	sol.timer.start(self, 50, function()
    		self:check()
  	end)
end


function panel:rebuild_surface()

  	self.surface:clear()
	self.brown_panel_img:draw_region(0, 0, 75, 75, self.surface, 0, 0)
	
end

function panel:set_dst_position(x, y)
  	self.dst_x = x
  	self.dst_y = y
end

function panel:on_draw(dst_surface)

  	local x, y = self.dst_x, self.dst_y
  	local width, height = dst_surface:get_size()
  	if x < 0 then
    		x = width + x
  	end
  	if y < 0 then
    		y = height + y
  	end
	self.surface:draw(dst_surface, x, y)
end

return panel

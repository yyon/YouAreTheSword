local panel = {}

local entitydata = require "enemies/entitydata"

local math = require "math"

function panel:new(game, type)
  	local object = {}
  	setmetatable(object, self)
  	self.__index = self
	
	object.type = type
	object.icon = icon

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
  	self.cooldownoverlay = sol.surface.create("hud/cooldown.png")

function self:on_started()
	self.danger_sound_timer = nil
  	self:check(nil)
  	self:rebuild_surface()

end

--  check heart data and fix periodically
function self:check()
	self:rebuild_surface()
  	-- check again in 50ms
  	sol.timer.start(self, 50, function()
    		self:check()
  	end)
end


function self:rebuild_surface()
	
  	self.surface:clear()
	self.brown_panel_img:draw_region(0, 0, 75, 75, self.surface, 0, 0)
	
	hero = self.game:get_hero().entitydata
	if hero ~= nil then
		ability = hero:getability(self.type)
		icon = ability.icon
		if self.icon ~= icon then
			self.icon = icon
			self.actualicon = sol.surface.create("icons_smaller/" .. self.icon .. ".png")
			print(self.actualicon, self.icon, self.type)
		end
		
		if self.actualicon ~= nil then
			self.actualicon:draw_region(0, 0, 69, 69, self.surface, 3, 3)
		end
		
		if ability.usingcooldown then
			fraction, timeremaining = ability:getremainingcooldown()
			frame = math.floor(fraction*100)
			self.cooldownoverlay:draw_region(69*frame, 0, 69, 69, self.surface, 3, 3)
		end
	end
end

function self:set_dst_position(x, y)
  	self.dst_x = x
  	self.dst_y = y
end

function self:on_draw(dst_surface)

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
end

return panel

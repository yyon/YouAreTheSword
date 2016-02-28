local possess_o_meter = {}

local entitydata = require "enemies/entitydata"

function possess_o_meter:new(game)

  	local object = {}
  	setmetatable(object, self)
  	self.__index = self

  	object:initialize(game)

  	return object
end

function possess_o_meter:initialize(game)

  	self.game = game
  	self.surface = sol.surface.create(90, 18)
  	self.dst_x = 0
  	self.dst_y = 0
  	self.empty_heart_sprite = sol.sprite.create("hud/possess_o_meter")
  	self.nb_max_hearts_displayed = game:get_max_life() / 4
  	self.nb_current_hearts_displayed = game:get_life()
  	self.all_sword_img = sol.surface.create("hud/sword_meter.png")
end

function possess_o_meter:on_started()
	self.danger_sound_timer = nil
  	self:check(nil)
  	self:rebuild_surface()

end

--  check heart data and fix periodically
function possess_o_meter:check(past_animation_stage)

  	local need_rebuild = false
	
	-- local animation_stage = 0
	
	if past_animation_stage == nil then
		past_animation_stage = 17
	end
	
	hero = game:get_hero().entitydata
    	if hero ~= nil then
		-- animation_stage = math.floor(hero.possess_clock / 7)
	end

--[[	if animation_stage ~= past_animation_stage then
		need_rebuild = true
		past_animation_stage = animation_stage
		
	end

	

  	-- redraw only if something has changed
  	if need_rebuild then
    		self:rebuild_surface(animation_stage)
  	end

--]]

  	-- check again in 50ms
  	sol.timer.start(self, 50, function()
    		self:check(past_animation_stage)
  	end)
end


function possess_o_meter:rebuild_surface(animation_stage)

  	self.surface:clear()

  	self.all_sword_img:draw_region(animation_stage * 112, 0, 112, 49, self.surface, x, y)
end

function possess_o_meter:set_dst_position(x, y)
  	self.dst_x = x
  	self.dst_y = y
end

function possess_o_meter:on_draw(dst_surface)

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

return possess_o_meter

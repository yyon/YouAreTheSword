local sword_health = {}

local entitydata = require "enemies/entitydata"


function sword_health:new(game)

  	local object = {}
  	setmetatable(object, self)
  	self.__index = self

  	object:initialize(game)

  	return object
end

function sword_health:initialize(game)

  	self.game = game
  	self.surface = sol.surface.create(112, 50)
  	self.dst_x = 0
  	self.dst_y = 0
	self.stage = 0
  	self.all_sword_img = sol.surface.create("hud/sword_health_meter.png")
	self.sword_anim_setup = sol.sprite.create("hud/soul_meter")
end

function sword_health:on_started()
	self.danger_sound_timer = nil
  	self:check(nil)
  	self:rebuild_surface()

end

--  check heart data and fix periodically
function sword_health:check()
	local stage = 16

	local hero = game:get_hero()
    if hero.entitydata ~= nil then
		self.stage = hero.entitydata.life / hero.entitydata.maxlife -- hero.swordhealth / hero.maxswordhealth
	end


	if self.game:is_started() then

    		if self.stage <= 4
        			and not self.game:is_suspended() then
      			if self.sword_anim_setup:get_animation() ~= "danger" then
        				self.sword_anim_setup:set_animation("danger")
      			end
    		elseif self.sword_anim_setup:get_animation() ~= "normal" then
      			self.sword_anim_setup:set_animation("normal")
    		end
  	end




    	self:rebuild_surface()

  	-- check again in 50ms
  	sol.timer.start(self, 100, function()
    		self:check()
  	end)
end


function sword_health:rebuild_surface()

  	self.surface:clear()
	self.sword_anim_setup:draw(self.surface,0,0)
	self.all_sword_img:draw_region(0,0,112,50,self.surface,0,0)
	self.all_sword_img:draw_region(112, 0, math.floor(self.stage*112), 50, self.surface, 0, 0)

end

function sword_health:set_dst_position(x, y)
  	self.dst_x = x
  	self.dst_y = y
end

function sword_health:on_draw(dst_surface)

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

return sword_health

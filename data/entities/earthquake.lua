local entity = ...

Effects = require "enemies/effect"
local math = require "math"

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start()
	self.lightning_sprite = self:create_sprite("abilities/earthquake")
	self.lightning_sprite:set_paused(false)
	
	self.orig_x, self.orig_y = self:get_position()
	
	function self.lightning_sprite.on_animation_finished (sword_sprite, sprite, animation)
		self.ticker:remove()
		self:remove()
	end
	
	self.collided = {}
	
	self.ticker = Effects.Ticker(self.ability.entitydata, 10, function() self:shake() end)

	self:add_collision_test("sprite", self.oncollision)
end

function entity:shake()
	dx = math.random(-50, 50)
	dy = math.random(-50, 50)
	x = self.orig_x + dx
	y = self.orig_y + dy
	self:set_position(x, y)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if self.collided[entity2] == nil then
			self.collided[entity2] = true

			self.ability:attack(entity2, self)
		end
	end
end

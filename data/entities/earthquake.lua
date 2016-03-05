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
		self:finish()
		self.ticker:remove()
		self:remove()
	end
	
	self.collided = {}
	self.origpos = {}
	
	self.ticker = Effects.Ticker(self.ability.entitydata, 50, function() self:shake() end)

	self:add_collision_test("sprite", self.oncollision)
end

function entity:shake()
	dx = math.random(-50, 50)
	dy = math.random(-50, 50)
	x = self.orig_x + dx
	y = self.orig_y + dy
	self:set_position(x, y)
	
	self:resetenemypos()
	for entity, iscollided in pairs(self.collided) do
		x, y = entity:get_position()
		x, y = x + dx, y + dx
		entity:set_position(x, y)
	end
--	map:move_camera(dx, dy, 500000, function() end, 0, 0)
end

function entity:finish()
	self:resetenemypos()
end

function entity:resetenemypos()
	for entity, pos in pairs(self.origpos) do
		entity:set_position(pos.x, pos.y)
	end
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if self.collided[entity2] == nil then
			self.collided[entity2] = true
			
			x, y = entity2:get_position()
			self.origpos[entity2] = {x=x, y=y}
			
			self.ability:attack(entity2, self)
		end
	end
end

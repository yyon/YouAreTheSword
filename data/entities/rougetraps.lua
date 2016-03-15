local entity = ...

Effects = require "enemies/effect"
require "scripts/movementaccuracy"

function entity:on_created()
end

function entity:start(tox, toy)
	self:set_optimization_distance(0)

	self.bomb_sprite = self:create_sprite("abilities/throwtraps")
	self.bomb_sprite:set_animation("stopped")
	self.bomb_sprite:set_paused(false)

	dist = self:get_distance(tox, toy)
	if dist > self.ability.range then
		dist = self.ability.range
	end

	local x, y = self:get_position()
	local angle = self:get_angle(tox, toy)-- + math.pi
	local movement = sol.movement.create("straight")
	movement:set_speed(600)
	movement:set_angle(angle)
	movement:set_max_distance(dist)
--	movement:set_smooth(true)
	movement:start(self)
	movementaccuracy(movement, angle, self)

	self.collided = {}
	self.timer = Effects.SimpleTimer:new(self.ability.entitydata, 1000, function() self:add_collision_test("sprite", self.oncollision) end)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if self.collided[entity2] == nil then
		self.collided[entity2] = true

		self.ability:attack(entity2, self)
	end
	
	self:remove()
end
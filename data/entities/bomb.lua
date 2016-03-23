local entity = ...

local Effects = require "enemies/effect"
require "scripts/movementaccuracy"

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start(tox, toy)
	self.bomb_sprite = self:create_sprite("abilities/bomb")
	self.bomb_sprite:set_animation("stopped")
	self.bomb_sprite:set_paused(false)

	self.isbomb = true
	self.exploded = false

	self.timer = Effects.SimpleTimer:new(self.ability.entitydata, 1000, function() self:startwarning() end)

	local dist = self:get_distance(tox, toy)
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

	sol.audio.play_sound("explode5")

	self.timer = Effects.SimpleTimer:new(self.ability.entitydata, 500, function() sol.audio.play_sound("explode5") end)
	self.timer = Effects.SimpleTimer:new(self.ability.entitydata, 1000, function() sol.audio.play_sound("explode5") end)
	self.timer = Effects.SimpleTimer:new(self.ability.entitydata, 1500, function() sol.audio.play_sound("explode5") end)
end

function entity:startwarning()
	self.bomb_sprite:set_animation("stopped_explosion_soon")

	self.timer = Effects.SimpleTimer:new(self.ability.entitydata, 1000, function() self:explode() end)
end

function entity:explode()
	sol.audio.play_sound("explode")

	self.exploded = true

	self:remove_sprite(self.bomb_sprite)

	self.collided = {}
	self:add_collision_test("sprite", self.oncollision)

	self.explode_sprite = self:create_sprite("abilities/explosion")
	self.explode_sprite:set_paused(false)
	function self.explode_sprite.on_animation_finished(explode_sprite, animation)
		self:remove()
	end
end

function entity:oncollision(entity2, sprite1, sprite2)
	if self.collided[entity2] == nil then
		self.collided[entity2] = true

		self.ability:attack(entity2, self)
	end
end

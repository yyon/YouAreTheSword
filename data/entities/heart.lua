local entity = ...

local Effects = require "enemies/effect"

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start(ability, target, playsound)
	if target == nil or target.entity == nil then self:remove(); return end

	self.ability = ability
	self:set_optimization_distance(0)

	self.target = target

	self.heart_sprite = self:create_sprite("abilities/heart")
	self.heart_sprite:set_paused(false)

	self.timer = Effects.SimpleTimer:new(self.ability.entitydata, 2000, function() self:remove() end)

--	local tox, toy = self.ability.entitydata:gettargetpos()

--	local dist = self:get_distance(tox, toy)
--	if dist > self.ability.range then
--		dist = self.ability.range
--	end

	local movement = sol.movement.create("target")
	movement:set_speed(600)
	movement:set_target(target.entity)
	movement:set_smooth(true)
	movement:start(self)
	function movement.on_finished(movement)
		self:heal()
		self:finish()
	end
	function movement.on_obstacle_reached(movement)
		self:finish()
	end
	self.movement = movement

	self.playsound = playsound

	self:add_collision_test("sprite", self.oncollision)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata == self.target then
		self:heal()
		self:finish()
	end
end

function entity:heal()
	if self.target.entity == nil then return end

	if self.playsound then sol.audio.play_sound("replenish") end
	self.ability:heal(self.target)
end

function entity:finish()
	self.timer:stop()
	self:remove()
	self.movement:stop()
end

function entity:isfast()
	return true
end
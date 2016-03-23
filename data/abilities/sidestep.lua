local class = require "middleclass"
local Ability = require "abilities/ability"
require "scripts/movementaccuracy"

local Effects = require "enemies/effect"

local SidestepAbility = Ability:subclass("SidestepAbility")
-- a replacement for sword ability for classes that don't have that animation

function SidestepAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Sidestep", 300, "sidestep", 0, 1000, true)
end

function SidestepAbility:doability()
	if not self:catch(self.entitydata) then return end

	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	self.entitydata:setanimation("walking")

	local angle = self.entitydata.entity:get_angle(tox, toy)
	local dist = self.entitydata.entity:get_distance(tox, toy)

	self.movement = sol.movement.create("straight")
	self.movement:set_speed(1000)
--	self.movement:set_target(tox, toy)
	self.movement:set_angle(angle)
	self.movement:set_max_distance(dist)
	self.movement:start(self.entitydata.entity)

	function self.movement.on_finished(movement)
		self:finish()
	end
	function self.movement.on_obstacle_reached(movement)
		self:finish()
	end

	movementaccuracy(self.movement, angle, self.entitydata.entity)

	sol.audio.play_sound("sidestep2")
	self.timer = Effects.SimpleTimer:new(self.entitydata, 100, function() sol.audio.play_sound("sidestep") end)
	self.timer = Effects.SimpleTimer:new(self.entitydata, 200, function() sol.audio.play_sound("sidestep2") end)
end

function SidestepAbility:oncancel()
	if self.movement ~= nil then
		self.movement:stop()
	end
end

function SidestepAbility:onfinish()
	self.entitydata:setanimation("stopped")
end

return SidestepAbility

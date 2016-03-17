local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local NormalAbility = Ability:subclass("NormalAbility")
-- a replacement for sword ability for classes that don't have that animation

function NormalAbility:initialize(entitydata, anim, aspects)
	if anim == nil then
		anim = "sword"
	end
	if aspects == nil then
		aspects = {}
	end
	self.aspects = aspects

	Ability.initialize(self, entitydata, "Attack", 50, "normal", 300, 0, true, anim)
end

function NormalAbility:doability(tox, toy)
	for entitydata in self.entitydata:getotherentities() do
		local d = self.entitydata.entity:get_distance(entitydata.entity)
		if d < 100 then
			if self.entitydata.entity:get_direction4_to(entitydata.entity) == self.entitydata:getdirection() or d<10 then
				self:dodamage(entitydata, 1, aspects)
			end
		end
	end

	sol.audio.play_sound("punch")

	self:finish()
end

return NormalAbility

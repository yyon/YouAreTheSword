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
	self.anim = anim

	Ability.initialize(self, entitydata, "Attack", 50, "normal", 0, 0, true, anim)
	
	self.stats = [[7 dmg]]
	self.desc = [[Generic attack for enemies]]
end

function NormalAbility:doability(tox, toy)
	for entitydata in self.entitydata:getotherentities() do
		if entitydata.entity ~= nil then
			local d = self.entitydata.entity:get_distance(entitydata.entity)
			if d < 100 then
				if self.entitydata.entity:get_direction4_to(entitydata.entity) == self.entitydata:getdirection() or d<10 then
					self:dodamage(entitydata, 1, self.aspects)
				end
			end
		end
	end

	sol.audio.play_sound("punch")

	self.entitydata:setanimation(self.anim)
	self.endtimer = Effects.SimpleTimer(self.entitydata, 300, function() self:finish() end)
end

return NormalAbility

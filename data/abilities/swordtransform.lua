local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local TransformAbility = Ability:subclass("TransformAbility")

function TransformAbility:initialize(entitydata, transform)
	local name
	local icon
	if transform == "ap" then
		name = "Axe"
		icon = "axe"
	elseif transform == "electric" then
		name = "Electric Sword"
		icon = "electricsword"
	elseif transform == "fire" then
		name = "Fire Sword"
		icon = "firesword"
	elseif transform == "poison" then
		name = "Poisoned Sword"
		icon = "poisonsword"
	elseif transform == "damage" then
		name = "Large Sword"
		icon = "largesword"
	elseif transform == "lifesteal" then
		name = "Lifesteal"
		icon = "lifestealsword"
	elseif transform == "holy" then
		name = "Holy Sword"
		icon = "holysword"
	elseif transform == "dagger" then
		name = "Dagger"
		icon = "dagger"
	elseif transform == "slow" then
		name = "Slow"
		icon = "slowness2"
	end

	Ability.initialize(self, entitydata, name, 0, icon, 500, 10000, true, "casting")

	self.transform = transform
end

function TransformAbility:doability()
	self.entitydata.entity.swordtransform = self.transform

	sol.audio.play_sound("enchant2")

	self:finish()
end

function TransformAbility:onfinish()
end

return TransformAbility

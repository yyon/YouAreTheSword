local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local TransformAbility = Ability:subclass("TransformAbility")

local SwordAbility = require "abilities/sword"

function TransformAbility:initialize(entitydata, transform)
	local name, icon = sworddesc.getnameicon(transform)

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

function TransformAbility:gettransform()
	return self.transform
end
function TransformAbility:getdesc()
		local desc = [[Transforms the sword
This is used with the "Swing Sword" ability

]]
	desc = desc .. sworddesc.getdesc(self:gettransform())
	return desc
end
function TransformAbility:getstats()
	return sworddesc.getstats(self:gettransform())
end

return TransformAbility

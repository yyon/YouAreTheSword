local map = ...
map.dialogprefix = "tutorialswordtransform."

local Effects = require "enemies/effect"
local LightningAbility = require "abilities/lightning"
local SwordAbility = require "abilities/sword"
local TransformAbility = require "abilities/swordtransform"

function map:on_opening_transition_finished()
	mage.entitydata.specialability = LightningAbility:new(mage.entitydata)
	mage.entitydata.swordability = SwordAbility:new(mage.entitydata)
	mage.entitydata.transformability = TransformAbility:new(mage.entitydata, "fire")
	function combatdummy.entitydata:isvisible() return false end
	combatdummy.entitydata.life = 1
	combatdummy.entitydata.maxlife = 1
	function combatdummy.entitydata:receivedamage(fromentitydata, damage, aspects)
		if aspects.fire == nil then
			return true
		end
		return false
	end
end

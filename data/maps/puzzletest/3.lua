local map = ...
local LightningAbility = require "abilities/lightning"

map.dialogprefix = "puzzletest."

function map:on_started()
	print("CREATED")
	local lightningability = LightningAbility:new(mage.entitydata)
	lightningability.warmup = 5000
	mage.entitydata.specialability = lightningability
	
	door_lever.entitydata.time = 2000
end

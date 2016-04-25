local map = ...

map.dialogprefix = "tutorial."

local Effects = require "enemies/effect"
local LightningAbility = require "abilities/lightning"

function map:on_opening_transition_finished()
	armordummy.entitydata.stats.defense = 1
	function armordummy.entitydata:isvisible() return false end
	
	mage.entitydata.specialability = LightningAbility:new(mage.entitydata)
	
	self:startcutscene()
	
	self:doend()
end

function map:doend()
	self:finish()
end

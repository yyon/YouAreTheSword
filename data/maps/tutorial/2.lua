local map = ...

map.dialogprefix = "tutorial2."

local Effects = require "enemies/effect"
local LightningAbility = require "abilities/lightning"
local SwordAbility = require "abilities/sword"

function map:on_opening_transition_finished()
	armordummy.entitydata.stats.defense = 1
	dummy2.entitydata.life = 1
	dummy2.entitydata.maxlife = 1
	function armordummy.entitydata:isvisible() return false end
	function dummy2.entitydata:isvisible() return false end
	knight.dialog = "knight"
	
	mage.entitydata.specialability = LightningAbility:new(mage.entitydata)
	mage.entitydata.swordability = SwordAbility:new(mage.entitydata)
	
	self:startcutscene()
	
	self:doend()
end

function map:doend()
	self:finish()
end

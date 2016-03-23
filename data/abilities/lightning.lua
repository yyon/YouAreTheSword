local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local LightningAbility = Ability:subclass("LightningAbility")

function LightningAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Lightning", 20000, "lightning", 2000, 20000, true, "casting")
end

function LightningAbility:doability()
	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	self.lightningentity = map:create_custom_entity({model="lightning", x=tox, y=toy, layer=2, direction=0, width=w, height=h})
	self.lightningentity.ability = self
	self.lightningentity:start(tox, toy)

	self:AOE(200, 4, {electric=3000, dontblock=true}, self.lightningentity)

	sol.audio.play_sound("thunder")

	self:finish()
end


return LightningAbility

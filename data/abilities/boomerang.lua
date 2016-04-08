local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local BoomerangAbility = Ability:subclass("BoomerangAbility")

function BoomerangAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "boomerang", 50, "boomerang", 0, 500, true, "casting")

	self.stats = [[5 dmg]]
	self.desc = [[Shoots an boomerang, will come back to you when reach maximum range. It will hit all enemies on its path.]]
end

function BoomerangAbility:doability()
	local tox, toy = self:gettargetpos()
 	self.tox, self.toy = tox, toy
 
 	local entity = self.entitydata.entity
 	local map = entity:get_map()
	local x,y,layer = entity:get_position()
 	local w,h = entity:get_size()
 	local entitydata = self.entitydata
 	local d = entitydata:getdirection()
 
 	self.boomerangentity = map:create_custom_entity({model="boomerang", x=x, y=y-35, layer=layer, direction=0, width=w, height=h})
	if self.boomerangentity == nil then self:cancel(); return end
 	self.boomerangentity.ability = self
 	self.boomerangentity:start(self, tox, toy)
	sol.audio.play_sound("shoot")

	self:finish()
end

function BoomerangAbility:onfinish()
end

return BoomerangAbility
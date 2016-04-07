local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local BoomerangAbility = Ability:subclass("BoomerangAbility")

function BoomerangAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "boomerang", 50, "boomerang", 0, 0, true, "casting")
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
 
 	self.boomerangentity:start(self, tox, toy, x, y)
	sol.audio.play_sound("shoot")

	self:finish()
end

function BoomerangAbility:onfinish()
end

return BoomerangAbility
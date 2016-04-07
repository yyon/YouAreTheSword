local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local FireballAbility = Ability:subclass("FireballAbility")

function FireballAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Fireball", 800, "fireball", 500, 2000, true, "casting")
	
	self.stats = [[7 Fire damage over 1 second]]
	self.desc = [[Shoots a fireball]]
end

function FireballAbility:doability()
	local tox, toy = self:gettargetpos()
	self.tox, self.toy = tox, toy

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	self.fireballentity = map:create_custom_entity({model="fireball", x=x, y=y, layer=layer, direction=0, width=w, height=h})
	self.fireballentity:start(self, tox, toy)

	sol.audio.play_sound("fireball")

	self:finish()
end

return FireballAbility

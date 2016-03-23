local class = require "middleclass"
local Ability = require "abilities/ability"

local BoulderAbility = Ability:subclass("FireballAbility")

function BoulderAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Meteor", 2000, "meteor", 0, 3000, true, "casting")
end

function BoulderAbility:doability()
	local tox, toy = self:gettargetpos()
	self.tox, self.toy = tox, toy

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	self.fireballentity = map:create_custom_entity({model="boulder", x=tox, y=2, layer=2, direction=0, width=w, height=h})
	self.fireballentity:start(self, tox, 999999)
	self.fireballentity:set_layer_independent_collisions(true)

	self:finish()
end

return BoulderAbility

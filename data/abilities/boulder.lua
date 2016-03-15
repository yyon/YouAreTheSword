local class = require "middleclass"
Ability = require "abilities/ability"

BoulderAbility = Ability:subclass("FireballAbility")

function BoulderAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Meteor", 2000, "meteor", 0, 500, true, "casting")
end

function BoulderAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	self.tox, self.toy = tox, toy

	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	self.fireballentity = map:create_custom_entity({model="boulder", x=tox, y=2, layer=2, direction=0, width=w, height=h})
	self.fireballentity:start(self, tox, 999999)
	self.fireballentity:set_layer_independent_collisions(true)

	self:finish()
end

return BoulderAbility

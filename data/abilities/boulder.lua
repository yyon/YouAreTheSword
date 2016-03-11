local class = require "middleclass"
Ability = require "abilities/ability"

BoulderAbility = Ability:subclass("FireballAbility")

function BoulderAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "BoulderAbility", 800, 3000, 5000, true, "casting")
end

function BoulderAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	self.tox, self.toy = tox, toy

	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	self.fireballentity = map:create_custom_entity({model="boulder", x=tox, y=50, layer=layer, direction=0, width=w, height=h})
	self.fireballentity:start(self, tox, 999999)

	self:finish()
end

return BoulderAbility

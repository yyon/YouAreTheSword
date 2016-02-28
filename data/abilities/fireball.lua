local class = require "middleclass"
Ability = require "abilities/ability"

FireballAbility = Ability:subclass("FireballAbility")

RANGE = 800

function FireballAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "FireballAbility", RANGE, 0, 500, true)
end

function FireballAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	self.tox, self.toy = tox, toy

	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	self.fireballentity = map:create_custom_entity({model="fireball", x=x, y=y, layer=layer, direction=0, width=w, height=h})
	self.fireballentity:start(self, tox, toy)

	self:finish()
end

return FireballAbility

local class = require "middleclass"
Ability = require "abilities/ability"

BombAbility = Ability:subclass("BombAbility")

function BombAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "bomb", 800, 500, 4000, true)
end

function BombAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	d = 0

	self.shieldentity = map:create_custom_entity({model="bomb", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.shieldentity.ability = self

	self.shieldentity:start(tox, toy)

	self:finish()
end

function BombAbility:onfinish()
end

function BombAbility:attack(entity, bombentity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	entitydata = entity.entitydata

	damage = 20
	aspects = {}
	aspects.fire = {damage=0.1, time=5000, timestep=500}
	aspects.fromentity = bombentity

	self:dodamage(entitydata, damage, aspects)
end

return BombAbility

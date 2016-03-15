local class = require "middleclass"
Ability = require "abilities/ability"

TrapsAbility = Ability:subclass("TrapsAbility")

function TrapsAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Trap", 800, "trap", 500, 4000, true)
end

function TrapsAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	d = 0

	self.shieldentity = map:create_custom_entity({model="rougetraps", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.shieldentity.ability = self

	self.shieldentity:start(tox, toy)

	self:finish()
end

function TrapsAbility:onfinish()
end

function TrapsAbility:attack(entity, trapentity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	entitydata = entity.entitydata

	damage = 2
	aspects = {}
	aspects.stun = 2000
	aspects.knockback = 0 

	self:dodamage(entitydata, damage, aspects)
end

return TrapsAbility

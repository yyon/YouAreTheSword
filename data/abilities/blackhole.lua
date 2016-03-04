local class = require "middleclass"
Ability = require "abilities/ability"

BlackHoleAbility= Ability:subclass("BlackHoleAbility")

function BlackHoleAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "BlackHoleAbility", 20000, 2000, 10000, true, "casting")
end

function BlackHoleAbility:doability()
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
	self.blackholeentity = map:create_custom_entity({model="blackhole", x=tox, y=toy, layer=layer, direction=0, width=w, height=h})
	self.blackholeentity.ability = self
	self.blackholeentity:start(tox, toy)

	self:finish()
end

function BlackHoleAbility:attack(entity, blackhole)
	if not self.entitydata:cantargetentity(entity) then
		return
	end
	
	entitydata = entity.entitydata

	damage = 4
	aspects = {}
	aspects.dontblock = true
	aspects.knockbackrandomangle = true
	aspects.fromentity = blackhole

	self:dodamage(entitydata, damage, aspects)
end


return BlackHoleAbility

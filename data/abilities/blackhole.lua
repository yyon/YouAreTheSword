local class = require "middleclass"
Ability = require "abilities/ability"

BlackHoleAbility= Ability:subclass("BlackHoleAbility")

RANGE = 20000

function EarthquakeAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "BlackHoleAbility", RANGE, 500, 10000, true)
end

function EarthquakeAbility:doability(tox, toy)
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	  dist = self.entitydata.entity:get_distance(tox, toy)
	  if dist > RANGE then
	    self:finish()
	    return
	  end
	
	self.blackholeentity = map:create_custom_entity({model="blackhole", x=tox, y=toy, layer=layer, direction=0, width=w, height=h})
	self.blackholeentity.ability = self
	self.blackholeentity:start(tox, toy)

	self:finish()
end

function EarthquakeAbility:attack(entity, blackhole)
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


return EarthquakeAbility
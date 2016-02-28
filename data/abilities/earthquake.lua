local class = require "middleclass"
Ability = require "abilities/ability"

EarthquakeAbility= Ability:subclass("EarthquakeAbility")

RANGE = 20000

function EarthquakeAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "EarthquakeAbility", RANGE, 500, 10000, true)
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
	
	self.earthquakeentity = map:create_custom_entity({model="earthquake", x=tox, y=toy, layer=layer, direction=0, width=w, height=h})
	self.earthquakeentity.ability = self
	self.earthquakeentity:start(tox, toy)

	self:finish()
end

function EarthquakeAbility:attack(entity, earthquake)
	if not self.entitydata:cantargetentity(entity) then
		return
	end
	
	entitydata = entity.entitydata

	damage = 4
	aspects = {}
	aspects.knockback = 1000
	aspects.dontblock = true
	aspects.fromentity = earthquake

	self:dodamage(entitydata, damage, aspects)
end


return EarthquakeAbility

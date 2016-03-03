local class = require "middleclass"
Ability = require "abilities/ability"

EarthquakeAbility= Ability:subclass("EarthquakeAbility")

function EarthquakeAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "EarthquakeAbility", 20000, 500, 10000, true)
end

function EarthquakeAbility:doability()
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
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
	aspects.knockbackrandomangle = true
	aspects.fromentity = earthquake
	

	self:dodamage(entitydata, damage, aspects)
end


return EarthquakeAbility

local class = require "middleclass"
Ability = require "abilities/ability"

TentacleAbility = Ability:subclass("NothingAbility")

local Effects = require "enemies/effect"
local math = require "math"

function TentacleAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Tentacles", 2000, "tentacles", 0, 500, true)
end

function TentacleAbility:doability()
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata
	
--	tox, toy = self.entitydata:gettargetpos()
--	tox, toy = self:withinrange(tox, toy)
	
	mapw, maph = map:get_size()
	tox, toy = math.random(1,mapw), math.random(1,maph) 
	
	self.entity = map:create_custom_entity({model="tentacle", x=tox, y=toy, layer=layer, direction=0, width=w, height=h})
	self.entity.ability = self
	self.entity:start(tox, toy)
	
	if math.random(1,2) == 1 then sol.audio.play_sound("slime" .. math.random(1,10)) end
	
	self:finish()
end

function TentacleAbility:attack(entity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end
	
	entitydata = entity.entitydata

	damage = 1
	aspects = {fromentity = self.entity}

	self:dodamage(entitydata, damage, aspects)
end

return TentacleAbility

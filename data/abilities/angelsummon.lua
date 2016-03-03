local class = require "middleclass"
Ability = require "abilities/ability"
--entitydatas = require "enemies/entitydata"

AngelSummonAbility = Ability:subclass("AngelSummonAbility")

RANGE = 20000

function AngelSummonAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "AngelSummonAbility", RANGE, 500, 10000, true)
end

function AngelSummonAbility:doability(tox, toy)
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
	
--	self.blackholeentity = map:create_custom_entity({model="blackhole", x=tox, y=toy, layer=layer, direction=0, width=w, height=h})
--	self.blackholeentity.ability = self
--	self.blackholeentity:start(tox, toy)
	
	newentity = map:create_enemy({
		breed="enemy_constructor",
		layer=layer,
		x=tox,
		y=toy,
		direction=0
	})
	
	angelentitydata = entitydatas.angelclass:new()
	angelentitydata.entity = newentity
	angelentitydata:applytoentity()

	self:finish()
end

return AngelSummonAbility

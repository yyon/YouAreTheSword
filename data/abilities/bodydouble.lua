local class = require "middleclass"
Ability = require "abilities/ability"
require "scripts/movementaccuracy"

BodyDoubleAbility = Ability:subclass("BodyDoubleAbility")

function BodyDoubleAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Body Double", 600, "bodydouble", 0, 10000, true)
end

function BodyDoubleAbility:doability()
	-- create dummy
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	newentity = map:create_enemy({
		breed="enemy_constructor",
		layer=layer,
		x=x,
		y=y,
		direction=0
	})
	
	dummyentitydata = entitydatas.dummyclass:new()
	dummyentitydata.team = self.entitydata.team
	dummyentitydata.entity = newentity
	dummyentitydata:applytoentity()
	
	-- teleport away
	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
	self.entitydata.entity:set_position(tox, toy)
	
	-- Change targets
	for entitydata in self.entitydata:getotherentities() do
		if not entitydata.entity.ishero then
			if entitydata.entity.entitytoattack == self.entitydata then
--				entitydata.entity.entitytoattack = dummyentitydata
				dummyentitydata:dodamage(entitydata, 0, {knockback=0})
			end
		end
	end
	
	self:finish()
end

return BodyDoubleAbility
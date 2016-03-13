local class = require "middleclass"
Ability = require "abilities/ability"

FiringBowAbility = Ability:subclass("FiringBowAbility")

function FiringBowAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "FiringBowAbility", 500, 270, 540, true, "firingbow")
end

function FiringBowAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	self.tox, self.toy = tox, toy
	
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata
	d = entitydata:getdirection()

	self.arrowentity = map:create_custom_entity({model="arrow", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.arrowentity:start(self, tox, toy)

	self:finish()
end

function FiringBowAbility:onfinish()
--	print("shit")
--	self.entitydata:setanimation("walking")
	
end

return FiringBowAbility
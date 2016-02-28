local class = require "middleclass"
Ability = require "abilities/ability"

LightningAbility = Ability:subclass("LightningAbility")

RANGE = 20000

function LightningAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "LightningAbility", RANGE, 500, 10000, true)
end

function LightningAbility:doability(tox, toy)
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

	self.lightningentity = map:create_custom_entity({model="lightning", x=tox, y=toy, layer=layer, direction=0, width=w, height=h})
	self.lightningentity.ability = self
	self.lightningentity:start(tox, toy)

	  self:AOE(200, 4, {electric=3000, dontblock=true}, self.lightningentity)

	self:finish()
end


return LightningAbility

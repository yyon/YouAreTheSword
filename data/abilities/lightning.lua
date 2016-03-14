local class = require "middleclass"
Ability = require "abilities/ability"

LightningAbility = Ability:subclass("LightningAbility")

function LightningAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Lightning", 20000, "lightning", 2000, 20000, true, "casting")
end

function LightningAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	self.lightningentity = map:create_custom_entity({model="lightning", x=tox, y=toy, layer=2, direction=0, width=w, height=h})
	self.lightningentity.ability = self
	self.lightningentity:start(tox, toy)

	  self:AOE(200, 4, {electric=3000, dontblock=true}, self.lightningentity)

	self:finish()
end


return LightningAbility

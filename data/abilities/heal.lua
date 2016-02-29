local class = require "middleclass"
Ability = require "abilities/ability"

HealAbility = Ability:subclass("HealAbility")

RANGE = 800

function HealAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "HealAbility", RANGE, 0, 500, true)
end

function HealAbility:doability()
	self.ticker = Effects.Ticker(self.blackhole.ability.entitydata, 100, function() self:sendheart() end)
end

function HealAbility:sendheart()
	tox, toy = self.entitydata:gettargetpos()
	targetentity = self.entitydata:getclosestentity(tox, toy)
	
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata
	
	self.healentity = map:create_custom_entity({model="heart", x=x, y=y, layer=layer, direction=0, width=w, height=h})
	self.healentity.ability = self
	self.healentity:start(self, targetentity)
end

function HealAbility:keyrelease()
	self:finish()
end

function HealAbility:onfinish()
	self.ticker:remove()
end

return FireballAbility

local class = require "middleclass"
Ability = require "abilities/ability"

HealAbility = Ability:subclass("HealAbility")

function HealAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Heal", 800, "heal", 0, 500, false, "casting")
	self.heals = true
end

function HealAbility:doability()
	self.ticker = Effects.Ticker(self.entitydata, 100, function() self:sendheart() end)
	self.i = 0
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
	self.i = self.i + 1
	self.healentity:start(self, targetentity, (self.i % 5 == 1))
end

function HealAbility:keyrelease()
	self:finish()
end

function HealAbility:onfinish()
	self.ticker:remove()
end

function HealAbility:heal(target)
	target.life = target.life + 0.1
	if target.life > target.maxlife then
		target.life = target.maxlife
	end
end

return HealAbility

local class = require "middleclass"
Ability = require "abilities/ability"

Effects = require "enemies/effect"

StealthAbility = Ability:subclass("StealthAbility")

math = require "math"

function StealthAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Stealth", 500, "stealth", 500, 10000, true)
end

function StealthAbility:doability()
	self.stealtheffect = Effects.StealthEffect(self.entitydata, 10000)
	self.ticker = Effects.Ticker(self.entitydata, 50, function() self:dotick() end)
	self.ticker:removeeffectafter(10000)
	
	self:finish()
end

function StealthAbility:dotick()
	map = self.entitydata.entity:get_map()
	w, h = self.entitydata.entity:get_size()
	x, y = self.entitydata.entity:get_position()
	dx, dy = math.random(-40, 40), math.random(-40, 40)
	
	self.smokeentity = map:create_custom_entity({model="stealth", x=x, y=y, layer=2, direction=0, width=w, height=h})
	self.smokeentity:start(self)
end

return StealthAbility

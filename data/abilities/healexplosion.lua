local class = require "middleclass"
Ability = require "abilities/ability"
local math = require "math"

HealExplosionAbility = Ability:subclass("HealExplosionAbility")

RANGE = 20000

function HealExplosionAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "HealExplosionAbility", RANGE, 500, 10000, true)
	self.heals = true
end

function HealExplosionAbility:doability(tox, toy)
	tox, toy = self.entitydata:gettargetpos()
	self.tox, self.toy = tox, toy
	print(tox, toy)

	dist = self.entitydata.entity:get_distance(tox, toy)
	if dist > RANGE then
		self:finish()
		return
	end
	
	self.ticker = Effects.Ticker(self.entitydata, 10, function() self:dotick() end)
	self.timer = Effects.SimpleTimer(self.entitydata, 100, function() self:finish() end)
end

function HealExplosionAbility:dotick()
	for i = 1,5 do
		entity = self.entitydata.entity
		map = entity:get_map()
		x,y,layer = entity:get_position()
		w,h = entity:get_size()
		entitydata = self.entitydata
	
		self.heartentity = map:create_custom_entity({model="heartexplosion", x=self.tox, y=self.toy, layer=layer, direction=0, width=w, height=h})
		self.heartentity.ability = self
		self.heartentity:start(self, math.random() * 2 * math.pi)
	end
end

function HealExplosionAbility:onfinish()
	self.timer:stop()
	self.ticker:remove()
end

function HealExplosionAbility:heal(target)
	target.life = target.maxlife
end

return HealExplosionAbility
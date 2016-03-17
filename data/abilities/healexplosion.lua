local class = require "middleclass"
local Ability = require "abilities/ability"
local math = require "math"
local Effects = require "enemies/effect"

local HealExplosionAbility = Ability:subclass("HealExplosionAbility")

function HealExplosionAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Heal Explosion", 20000, "healexplosion", 500, 10000, true, "casting")
	self.heals = true
end

function HealExplosionAbility:doability(tox, toy)
	local tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	self.tox, self.toy = tox, toy

	self.ticker = Effects.Ticker(self.entitydata, 50, function() self:dotick() end)
	self.timer = Effects.SimpleTimer(self.entitydata, 100, function() self:finish() end)

	sol.audio.play_sound("heal")
end

function HealExplosionAbility:dotick()
	for i = 1,10 do
		local entity = self.entitydata.entity
		local map = entity:get_map()
		local x,y,layer = entity:get_position()
		local w,h = entity:get_size()
		local entitydata = self.entitydata

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
	if target.team == self.entitydata.team then
		target.life = target.maxlife
	end
end

return HealExplosionAbility

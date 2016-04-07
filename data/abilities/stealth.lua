local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local StealthAbility = Ability:subclass("StealthAbility")

local math = require "math"

function StealthAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Stealth", 500, "stealth", 500, 10000, true)
	self.stats = [[Stealth 10s]]
	self.desc = [[Becomes invisible to enemies]]
end

function StealthAbility:doability()
	self.stealtheffect = Effects.StealthEffect(self.entitydata, 10000)
	self.ticker = Effects.Ticker(self.entitydata, 50, function() self:dotick() end)
	self.ticker:removeeffectafter(10000)

	sol.audio.play_sound("stealth")

	self:finish()
end

function StealthAbility:dotick()
	local map = self.entitydata.entity:get_map()
	local w, h = self.entitydata.entity:get_size()
	local x, y = self.entitydata.entity:get_position()
	local dx, dy = math.random(-40, 40), math.random(-40, 40)

	self.smokeentity = map:create_custom_entity({model="stealth", x=x, y=y, layer=2, direction=0, width=w, height=h})
	self.smokeentity:start(self)
end

return StealthAbility

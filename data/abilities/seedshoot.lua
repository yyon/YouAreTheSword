local class = require "middleclass"
local Ability = require "abilities/ability"
local Effects = require "enemies/effect"

local SeedShootAbility = Ability:subclass("SeedShootAbility")

function SeedShootAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Shoot Seeds", 800, "fireball", 0, 5000, true, "casting")
end

function SeedShootAbility:doability()
	self.ticker = Effects.Ticker(self.entitydata, 100, function() self:firevolley() end)
	self.timer = Effects.SimpleTimer(self.entitydata, 700, function() self:finish() end)
end

function SeedShootAbility:firevolley()
	local tox, toy = self:gettargetpos()
	
	sol.audio.play_sound("swish13")
	
	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	self.fireballentity = map:create_custom_entity({model="seed", x=x, y=y, layer=layer, direction=0, width=w, height=h})
	self.fireballentity:start(self, tox, toy)
end

function SeedShootAbility:onfinish()
	self.ticker:remove()
	self.timer:stop()
end

return SeedShootAbility

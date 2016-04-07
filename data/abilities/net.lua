local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local NetAbility = Ability:subclass("NetAbility")

function NetAbility:initialize(entitydata, spritename)
	self.spritename = spritename
	Ability.initialize(self, entitydata, "Net", 800, "net", 500, 2000, true)
	
	self.stats = [[Slowness 15s]]
	self.desc = [[Enemy gets tangled up in net.
Reduces enemy's movement speed, increases casting time, and cooldown time]]
end

function NetAbility:doability()
	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	local d = 0

	self.netentity = map:create_custom_entity({model="net", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.netentity.ability = self
	self.netentity.spritename = self.spritename

	self.netentity:start(self, tox, toy)

	sol.audio.play_sound("swish5")
	
	self:finish()
end

function NetAbility:onfinish()
end

return NetAbility

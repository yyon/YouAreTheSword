local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local SlowAbility = Ability:subclass("Slow")

local Effects = require "enemies/effect"

function SlowAbility:doability()
	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

--	self.slowentity = map:create_custom_entity({model="slow", x=tox, y=toy, layer=2, direction=0, width=w, height=h})
--	self.slowentity.ability = self
--	self.slowentity:start(tox, toy)

--	self:AOE(200, 4, {electric=3000, dontblock=true}, self.lightningentity)

--	sol.audio.play_sound("slow")

	self:finish()
end


return SlowAbility
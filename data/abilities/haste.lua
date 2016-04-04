local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local HasteAbility = Ability:subclass("Haste")

local Effects = require "enemies/effect"

function HasteAbility:doability()
	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata
	


--	self.hasteentity = map:create_custom_entity({model="haste", x=tox, y=toy, layer=2, direction=0, width=w, height=h})
--	self.hasteentity.ability = self
--	self.hasteentity:start(tox, toy)

--	self:AOE(200, 4, {electric=3000, dontblock=true}, self.lightningentity)

--	sol.audio.play_sound("haste")

	self:finish()
end


return HasteAbility
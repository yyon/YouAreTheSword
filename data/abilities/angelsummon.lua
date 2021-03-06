local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"
--local entitydatas = _EntityDatas-- or  require "enemies/entitydata"

local AngelSummonAbility = Ability:subclass("AngelSummonAbility")

function AngelSummonAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Summon Angel", 20000, "angel", 2000, 30000, true, "casting")
	self.desc = [[Summons an angel]]
end

function AngelSummonAbility:doability()
	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

--	self.blackholeentity = map:create_custom_entity({model="blackhole", x=tox, y=toy, layer=layer, direction=0, width=w, height=h})
--	self.blackholeentity.ability = self
--	self.blackholeentity:start(tox, toy)

	local newentity = map:create_enemy({
		breed="enemy_constructor",
		layer=layer,
		x=tox,
		y=toy,
		direction=0
	})
	if newentity == nil then self:cancel(); return end

	local angelentitydata = _EntityDatas.angelclass:new()
	angelentitydata.entity = newentity
	angelentitydata:applytoentity()
	map:addperson(angelentitydata)

	sol.audio.play_sound("blessing")

	self:finish()
end

return AngelSummonAbility

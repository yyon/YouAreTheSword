local class = require "middleclass"
local Ability = require "abilities/ability"
require "scripts/movementaccuracy"

local Effects = require "enemies/effect"

local BodyDoubleAbility = Ability:subclass("BodyDoubleAbility")

function BodyDoubleAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Body Double", 600, "bodydouble", 0, 10000, true)
	self.desc = [[Teleports away, leaving a combat dummy in its place
Enemies which were previously attacking user will now attack combat dummy]]
end

function BodyDoubleAbility:doability()
	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	local canteleport = self.entitydata:canmoveto(tox, toy)

	if canteleport then
		-- create dummy
		local entity = self.entitydata.entity
		local map = entity:get_map()
		local x,y,layer = entity:get_position()
		local w,h = entity:get_size()
		local entitydata = self.entitydata

		local newentity = map:create_enemy({
			breed="enemy_constructor",
			layer=layer,
			x=x,
			y=y,
			direction=0
		})

		local dummyentitydata = _EntityDatas.dummyclass:new()
		dummyentitydata.team = self.entitydata.team
		dummyentitydata.actualteam = self.entitydata.actualteam
		dummyentitydata.entity = newentity
		dummyentitydata:applytoentity()

		-- teleport away

		self.entitydata.entity:set_position(tox, toy)

		-- Change targets
		for entitydata in self.entitydata:getotherentities() do
			if not entitydata.entity.ishero then
				if entitydata.entity.entitytoattack == self.entitydata then
--					entitydata.entity.entitytoattack = dummyentitydata
					dummyentitydata:dodamage(entitydata, 0, {knockback=0})
				end
			end
		end

		self:finish()
	else
		self:finish(true)
	end
end

return BodyDoubleAbility

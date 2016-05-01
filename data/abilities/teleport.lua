local class = require "middleclass"
local Ability = require "abilities/ability"
require "scripts/movementaccuracy"

local Effects = require "enemies/effect"

local TeleportAbility = Ability:subclass("TeleportAbility")

function TeleportAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Teleporter", 600, "teleport", 0, 2550, true)
	self.desc = [[Teleports to mouse pointer]]
end

function TeleportAbility:doability()
	if not self:catch(self.entitydata) then
		self:finish(true)
		return
	end
	
	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	local canteleport = self.entitydata:canmoveto(tox, toy)

	if canteleport then
		self.entitydata.entity:set_position(tox, toy)

		-- animation
		local entity = self.entitydata.entity
		local map = entity:get_map()
		local x,y,layer = entity:get_position()
		local w,h = entity:get_size()
		local entitydata = self.entitydata

		self.teleportentity = map:create_custom_entity({model="teleportanim", x=x, y=y, layer=2, direction=0, width=w, height=h})

		sol.audio.play_sound("teleport")

		self:finish()
	else
		self:finish(true)
	end
end

return TeleportAbility

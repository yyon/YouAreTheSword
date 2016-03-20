local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local ShieldAbility = Ability:subclass("ShieldAbility")

function ShieldAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Shield", 50, "shield", 0, 500, true)
end

function ShieldAbility:doability()
	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	local d = entitydata:getdirection()

	self.shieldentity = map:create_custom_entity({model="shield", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.shieldentity.ability = self

--	self.entitydata:setanimation("stopped_with_shield")

	self.shieldentity:start("adventurers/shield")

--	self.playerrelease = playerrelease
	if not self.entitydata.entity.ishero then
		self.timer = Effects.SimpleTimer(self.entitydata, 1000, function() self:finish() end)
	end
end

function ShieldAbility:onfinish()
	self.entitydata:setanimation("walking")

	if self.timer ~= nil then
		self.timer:stop()
	end

	self.shieldentity:remove()
	self.shieldentity = nil
end

function ShieldAbility:blockdamage(fromentity, damage, aspects)
	if self.entitydata.entity:get_direction4_to(fromentity.entity) == self.entitydata:getdirection() then
		-- shield can block
--		self.entitydata:log("Blocked Damage using shield!")
		aspects.reversecancel = 500
		sol.audio.play_sound("shield")
		return 0, aspects
	end

	return damage, aspects
end

function ShieldAbility:tick(x, y)
	local hero = self.entitydata.entity
	local direct = hero:get_direction4_to(x, y)
	hero:set_direction(direct)
	self.shieldentity:set_direction(direct)
	self.shieldentity:updatedirection()
end

function ShieldAbility:keyrelease()
	self:finish()
end

return ShieldAbility

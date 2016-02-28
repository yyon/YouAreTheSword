local class = require "middleclass"
Ability = require "abilities/ability"

ShieldAbility = Ability:subclass("ShieldAbility")

function ShieldAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "shield", 50, 0, 500, true)
end

function ShieldAbility:doability(playerrelease)
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	print(layer)

	d = entitydata:getdirection()

	self.shieldentity = map:create_custom_entity({model="shield", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.shieldentity.ability = self

--	self.entitydata:setanimation("stopped_with_shield")

	self.shieldentity:start("adventurers/shield")

	self.playerrelease = playerrelease
	if not self.playerrelease then
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
	self.entitydata:log("sword finish 2")
end

function ShieldAbility:blockdamage(fromentity, damage, aspects)
	if self.entitydata.entity:get_direction4_to(fromentity.entity) == self.entitydata:getdirection() then
		-- shield can block
		self.entitydata:log("Blocked Damage using shield!")
		aspects.reversecancel = 500
		return 0, aspects
	end

	return damage, aspects
end

function ShieldAbility:tick(x, y)
	hero = self.entitydata.entity
	direct = hero:get_direction4_to(x, y)
	hero:set_direction(direct)
	self.shieldentity:set_direction(direct)
	self.shieldentity:updatedirection()
end

return ShieldAbility

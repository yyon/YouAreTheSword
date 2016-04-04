local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local NetAbility = Ability:subclass("NetAbility")

function NetAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Net", 800, "net", 500, 4000, true)
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

	self.shieldentity = map:create_custom_entity({model="net", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.shieldentity.ability = self

	self.shieldentity:start(tox, toy)

	self:finish()
end

function NetAbility:onfinish()
end

function NetAbility:attack(entity, trapentity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	self.shieldentity:remove()

	local entitydata = entity.entitydata

	local damage = 0
	local aspects = {}
	aspects.stun = 10000
	aspects.knockback = 0

	self:dodamage(entitydata, damage, aspects)
end

return NetAbility

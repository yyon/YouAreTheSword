local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local BombAbility = Ability:subclass("BombAbility")

function BombAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Bomb", 800, "bomb", 500, 4000, true)
end

function BombAbility:doability()
	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	local d = 0

	self.shieldentity = map:create_custom_entity({model="bomb", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.shieldentity.ability = self

	self.shieldentity:start(tox, toy)

	self:finish()
end

function BombAbility:onfinish()
end

function BombAbility:attack(entity, bombentity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	local entitydata = entity.entitydata

	local damage = 20
	local aspects = {}
	aspects.fire = {damage=0.1, time=5000, timestep=500}
	aspects.fromentity = bombentity

	self:dodamage(entitydata, damage, aspects)
end

return BombAbility

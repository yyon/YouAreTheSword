local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local BlackHoleAbility= Ability:subclass("BlackHoleAbility")

function BlackHoleAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Black Hole", 20000, "blackhole", 2000, 30000, true, "casting")
	self.caughtduringabilityuse = false
	self.stats = [[Immobilizes 3s
14 dmg]]
	self.desc = [[Creates a black hole, sucking in all nearby enemies
Disappears after 3s, damages enemies and shoots them out]]
end

function BlackHoleAbility:doability()
	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	self.blackholeentity = map:create_custom_entity({model="blackhole", x=tox, y=toy, layer=layer, direction=0, width=8, height=8})
	if self.blackholeentity == nil then self:cancel(); return end
	self.blackholeentity.ability = self
	self.blackholeentity:start(tox, toy)

	self:finish()
end

function BlackHoleAbility:attack(entity, blackhole)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	local entitydata = entity.entitydata

	local damage = 2
	local aspects = {}
	aspects.dontblock = true
	aspects.knockbackrandomangle = true
	aspects.fromentity = blackhole

	self:dodamage(entitydata, damage, aspects)
end

return BlackHoleAbility

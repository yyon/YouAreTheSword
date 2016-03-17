local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local TrapsAbility = Ability:subclass("TrapsAbility")

function TrapsAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Trap", 800, "trap", 500, 4000, true)
end

function TrapsAbility:doability()
	local tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	local d = 0

	self.shieldentity = map:create_custom_entity({model="rougetraps", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.shieldentity.ability = self

	self.shieldentity:start(tox, toy)

	sol.audio.play_sound("trap")

	self:finish()
end

function TrapsAbility:onfinish()
end

function TrapsAbility:attack(entity, trapentity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	self.shieldentity:remove()

	local entitydata = entity.entitydata

	local damage = 20
	local aspects = {}
	aspects.stun = 2000
	aspects.knockback = 0

	self:dodamage(entitydata, damage, aspects)
end

return TrapsAbility

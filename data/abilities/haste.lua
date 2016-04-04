local class = require "middleclass"
local Ability = require "abilities/ability"

local HasteAbility = Ability:subclass("HasteAbility")

local Effects = require "enemies/effect"

function HasteAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Haste", 1000, "speed", 500, 10000, true, "casting")
end

function HasteAbility:doability()

	local tox, toy = self:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	self.hasteentity = map:create_custom_entity({model="haste", x=tox, y=toy, layer=layer, direction=0, width=w, height=h})
	self.hasteentity.ability = self
	self.hasteentity:start()

end

function HasteAbility:onfinish()
end

function HasteAbility:attack(entity)
	local entitydata = entity.entitydata

	local damage = 0
	local aspects = {}
	aspects.haste = true
	aspects.onlyonsameteam = true
	self:dodamage(entitydata, damage, aspects)
end

return HasteAbility

local class = require "middleclass"
local Ability = require "abilities/ability"

local HasteAbility = Ability:subclass("HasteAbility")

local Effects = require "enemies/effect"

function HasteAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Stomp", 1000, "stomp", 500, 10000, true, "casting")
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
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	local entitydata = entity.entitydata

	local damage = 3
	local aspects = {knockback=1000}

	self:dodamage(entitydata, damage, aspects)
end

return HasteAbility

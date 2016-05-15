local class = require "middleclass"
local Ability = require "abilities/ability"

local TentacleAbility = Ability:subclass("NothingAbility")

local Effects = require "enemies/effect"
local math = require "math"

function TentacleAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Tentacles", 2000, "tentacles", 0, 200, true)

	self.stats = [[7 dmg]]
	self.desc = [[Creates a tentacle on a random point on the map]]
end

function TentacleAbility:doability()
	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

--	tox, toy = self.entitydata:gettargetpos()
--	tox, toy = self:withinrange(tox, toy)

	local mapw, maph = map:get_size()
	local tox, toy = math.random(1,mapw), math.random(1,maph)

	self.entity = map:create_custom_entity({model="tentacle", x=tox, y=toy, layer=layer, direction=0, width=w, height=h})
	self.entity.ability = self
	self.entity:start(tox, toy)

	if math.random(1,2) == 1 then sol.audio.play_sound("slime" .. math.random(1,10)) end

	self:finish()
end

function TentacleAbility:attack(entity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	local entitydata = entity.entitydata

	local damage = 1
	local aspects = {fromentity = self.entity, knockbackrandomangle = true}

	self:dodamage(entitydata, damage, aspects)
end

return TentacleAbility

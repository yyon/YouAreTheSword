local class = require "middleclass"
local Ability = require "abilities/ability"
require "scripts/movementaccuracy"

local Effects = require "enemies/effect"

local SwordAbility = require "abilities/sword"

local ChargeAbility = Ability:subclass("ChangeAbility")

function ChargeAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Charge", 800, "charge", 0, 2000, true)
end

function ChargeAbility:doability(tox, toy)
	if not self:catch(self.entitydata) then return end

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	self.collided = {}

	local d = entitydata:getdirection()

	self.swordentity = map:create_custom_entity({model="charge", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.swordentity.ability = self

	self.entitydata:setanimation("charge")

	self.swordentity:start(SwordAbility:get_appearance(self.entitydata.entity))

	local dist = self.entitydata.entity:get_distance(tox, toy)
	if dist > self.range then
		dist = self.range
	end

	local x, y = self.entitydata.entity:get_position()
	local angle = self.entitydata.entity:get_angle(tox, toy)-- + math.pi
	local movement = sol.movement.create("straight")
	movement:set_speed(600)
	movement:set_angle(angle)
	movement:set_max_distance(dist)
	movement:start(self.entitydata.entity)
	local ca = self
	function movement:on_position_changed()
		if ca.swordentity == nil then ca:finish() return end
		ca.swordentity:updatepos()
	end
	function movement.on_obstacle_reached(movement)
		ca:finish()
	end
	function movement.on_finished(movement)
		ca:finish()
	end
	movementaccuracy(movement, angle, self.entitydata.entity)

	self.entitydata.positionlisteners[self] = function(x, y, layer) self:updatepos(x, y, layer) end
end

function ChargeAbility:onfinish()
	self.entitydata:setanimation("walking")

	self.entitydata.positionlisteners[self] = nil

	self.entitydata.entity:stop_movement()
	self.swordentity:remove()
	self.swordentity = nil
end

function ChargeAbility:blockdamage(fromentity, damage, aspects)
	aspects.donothing=true
	return 0, aspects
end

function ChargeAbility:updatepos(x, y, layer)
	local entity = self.entitydata.entity
	local map = entity:get_map()

--[[
	for entitydata2 in self.entitydata:getotherentities() do
		entity2 = entitydata2.entity
		if self.entitydata.entity:overlaps(entity2) then
			if self.entitydata:cantarget(entitydata2) then
				if self.collided[entity2] == nil then
					self.collided[entity2] = true

					self:attack(entitydata2)
				end
			end
		end
	end
--]]
end

function ChargeAbility:attack(entity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	local entitydata = entity.entitydata

	local damage = 2
	local aspects = {stun=500, knockback=0}

	self:dodamage(entitydata, damage, aspects)

	self:finish()

	self.entitydata:startability("normal")
end

return ChargeAbility

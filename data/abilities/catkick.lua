local class = require "middleclass"
local Ability = require "abilities/ability"
require "scripts/movementaccuracy"

local Effects = require "enemies/effect"

local CatKickAbility = Ability:subclass("CatKickAbility")

function CatKickAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Cat Kick", 800, "", 500, 2000, true, "kick-ready")
end

function CatKickAbility:doability()
	if not self:catch(self.entitydata) then return end
	
	local tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	self.collided = {}

	local d = entitydata:getdirection()

	self.swordentity = map:create_custom_entity({model="catattack", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.swordentity.ability = self

	self.entitydata:setanimation("invisible")

	self.swordentity:start(self.entitydata.main_sprite, "kick")

	local dist = self.entitydata.entity:get_distance(tox, toy)
	if dist > self.range then
		dist = self.range
	end

	local x, y = self.entitydata.entity:get_position()
	local angle = self.entitydata.entity:get_angle(tox, toy)-- + math.pi
	self.angle = angle
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
end

function CatKickAbility:onfinish()
	if self.endtimer ~= nil then
		self.endtimer:stop()
	end
	
	self.entitydata:setanimation("walking")

	self.entitydata.entity:stop_movement()
	
	if self.swordentity ~= nil then
		self.swordentity:remove()
		self.swordentity = nil
	end
end

--function CatKickAbility:blockdamage(fromentity, damage, aspects)
--	aspects.donothing=true
--	return 0, aspects
--end

function CatKickAbility:attack(entity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	local entitydata = entity.entitydata

	local damage = 2
	local aspects = {stun=500, knockback=1000, knockbackangle=self.angle}
	
	self:dodamage(entitydata, damage, aspects)
	
	if self.swordentity ~= nil then
		self.swordentity:remove()
		self.swordentity = nil
	end
	
	self.entitydata:setanimation("kick-end")
	
	self.entitydata.entity:stop_movement()
	
	self.endtimer = Effects.SimpleTimer(self.entitydata, 500, function() self:finish() end)
end

return CatKickAbility

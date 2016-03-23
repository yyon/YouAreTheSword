local class = require "middleclass"
local Ability = require "abilities/ability"
require "scripts/movementaccuracy"

local Effects = require "enemies/effect"

local math = require "math"

local CatKickAbility = Ability:subclass("CatKickAbility")

function CatKickAbility:initialize(entitydata, type)
	self.type = type
	local warmup
	local warmuptime
	if type == "kick" then
		warmup = "kick-ready"
		warmuptime = 500
	elseif type == "downkick" then
		warmup = "downkick-ready"
		warmuptime = 500
	elseif type == "spin" then
		warmup = "spin-ready"
		warmuptime = 300
	elseif type == "uppercut" then
		warmup = "uppercut-ready"
		warmuptime = 300
	end
	Ability.initialize(self, entitydata, "Cat Attack", 800, "", warmuptime, 2000, true, warmup)
end

function CatKickAbility:doability()
	if not self:catch(self.entitydata) then return end
	
	local tox, toy = self:gettargetpos()
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
	
	local anim
	if self.type == "kick" then
		anim = "kick"
	elseif self.type == "downkick" then
		anim = "downkick"
	elseif self.type == "spin" then
		anim = "spin"
	elseif self.type == "uppercut" then
		anim = "uppercut"
	end
	
	self.swordentity:start(self.entitydata.main_sprite, anim)

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

	local damage
	local aspects = {stun=500, knockback=1000}
	local anim
	if self.type == "kick" then
		anim = "kick-end"
		damage = 1
		aspects.knockbackangle=self.angle
	elseif self.type == "downkick" then
		anim = "downkick-end"
		damage = 2
		aspects.knockbackangle=math.pi * 3 / 2
	elseif self.type == "spin" then
		anim = "spin-end"
		damage = 2
		aspects.knockbackangle=math.pi * 3 / 2
	elseif self.type == "uppercut" then
		anim = "uppercut-end"
		damage = 2
		aspects.knockbackangle=math.pi * 1 / 2
	end
	
	self:dodamage(entitydata, damage, aspects)
	
	sol.audio.play_sound("punch")
	
	if self.swordentity ~= nil then
		self.swordentity:remove()
		self.swordentity = nil
	end
	
	self.entitydata:setanimation(anim)
	
	self.entitydata.entity:stop_movement()
	
	self.endtimer = Effects.SimpleTimer(self.entitydata, 500, function() self:finish() end)
end

return CatKickAbility

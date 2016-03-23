local entity = ...

local math = require "math"
local Effects = require "enemies/effect"
require "scripts/movementaccuracy"

function entity:on_created()
	self:set_optimization_distance(0)
	self.speed = 600
end

local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function entity:start(ability, tox, toy)
	self.ability = ability

	self.sprite = self:create_sprite(self:getspritename())
	self.sprite:set_paused(false)
	self.sprite:set_direction(self:get_direction())

	if self.anim ~= nil then
		self.sprite:set_animation(self.anim)
	end

--	local x, y = self:get_position()
	local angle
	if self:isangle() then
		angle = tox
	else
		angle = self:get_angle(tox, toy)-- + math.pi
	end
	self.angle = angle

	if self.rotationframes ~= nil then
		local frame = round((-angle + math.pi / 2) * self.rotationframes / math.pi / 2)
		if self.framenegative then
			frame = -frame
		end
		if self.rotationframesoffset ~= nil then
			frame = frame + self.rotationframesoffset
		end
		frame = frame % self.rotationframes
		self.sprite:set_frame(frame)
		self.sprite:set_paused(true)
	end

	local movement = sol.movement.create("straight")
	movement:set_speed(self:getspeed())
	movement:set_angle(angle)
	movement:set_max_distance(self:getmaxdist())
--	movement:set_target(tox, toy)
	if self:noobstacles() then
		 movement:set_ignore_obstacles(true)
	end
	movement:start(self)

	self.movement = movement

	function movement.on_obstacle_reached(movement)
		self:finish()
	end
	function movement.on_finished(movement)
		self:finish()
	end
	
	if not self:isfast() then
		function movement.on_position_changed(movement)
			self:onposchanged()
		end
		movementaccuracy(movement, angle, self)
		self:add_collision_test("overlapping", self.overlap)
	end

	self.collided = {}
	self:add_collision_test("sprite", self.oncollision)

	self:onstart()
end

function entity:overlap(entity2)
	if entity2:get_type() == "wall" then
		local name = entity2:get_name()
		if name == nil or not string.find(name, "proj") then
			self:finish()
		end
	end
end

function entity:finish()
	self.movement:stop()

	self:onfinished()
	self:remove()
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if self.collided[entity2] == nil then
			self.collided[entity2] = true

			self:doattack(entity2.entitydata)
		end
	end
end

function entity:doattack(entitydata)
	local damage, aspects = self:getdamage()
	if self.ability.entitydata:cantarget(entitydata) then
		self.ability:dodamage(entitydata, damage, aspects)
		self:onhit()
	end
end

-- methods to overwrite:

function entity:onfinished()
end
function entity:onhit()
end

function entity:isangle()
	return self.is_angle
end

function entity:getspeed()
	return self.speed
end

function entity:getmaxdist()
	return 1200
end

function entity:noobstacles()
	return self.no_obstacles
end

function entity:onposchanged()
end

function entity:getdamage()
	return 1, {}
end

function entity:getspritename()
	return self.sprite_name
end

function entity:onstart()
end

function entity:isfast()
	return false
end

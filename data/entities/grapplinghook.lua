local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

require "scripts/movementaccuracy"

function entity:on_created()
	self:set_optimization_distance(0)
end

local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function entity:start(target, type)
	self.target = target
	self.type = type

	self.d4 = self.ability.entitydata.entity:get_direction4_to(self.target.entity)
	self.d8 = self.ability.entitydata.entity:get_direction8_to(self.target.entity)
	local angle = self.ability.entitydata.entity:get_angle(self.target.entity)

	self.d16 = round(-angle * 24 / math.pi / 2) % 24


	self.hooksprite = self:create_sprite("abilities/grapplinghook")
	if self.type == nil then
		self.hooksprite:set_animation("hook")
	elseif self.type == "vine" then
		self.hooksprite:set_animation("vine")
	end
	self.hooksprite:set_paused(false)
	self.hooksprite:set_direction(self.d8)

	self.ropesprites = {}

--	local x, y = self:get_position()
--	local angle = self:get_angle(tox, toy)-- + math.pi
	local movement = sol.movement.create("target")
	movement:set_speed(600)
	movement:set_target(self.target.entity)
--	movement:set_max_distance(dist)
	movement:start(self)
	function movement.on_finished(movement)
--		print("FINISH")
		self.ability:attack(self.target.entity, self)
--		self.ability:cancel()
	end
	function movement.on_obstacle_reached(movement)
--		print("OBSTACLE")
		self.ability:cancel()
	end
	function movement.on_position_changed(movement)
		self:tick()
	end

	self:add_collision_test("sprite", self.oncollision)

	targetstopper(movement, self, self.target.entity)

--	self.ticker = Effects.Ticker(self.ability.entitydata, 50, function() self:tick() end)
end

function entity:pull(target)
	self.pulling = true
	self.target = target
	self:clear_collision_tests()

	local movement = sol.movement.create("target")
	movement:set_speed(600)
	movement:set_target(self.ability.entitydata.entity)
	movement:start(self)
	function movement.on_position_changed(movement)
		self:tick()
	end

	targetstopper(movement, self, self.ability.entitydata.entity)
end

local SPACING = 36--18

function entity:tick()
	local d = self:get_distance(self.ability.entitydata.entity)

	local selfx, selfy, layer = self:get_position()
	local entityx, entityy = self.ability.entitydata.entity:get_position()
	entityy = entityy - 10

	local map = self:get_map()

	for i = SPACING,d,SPACING do
		local posx, posy = selfx * (d - i)/d + entityx * i/d,  selfy * (d - i)/d + entityy * i/d
		if self.ropesprites[i] == nil then
			self.ropesprites[i] = map:create_custom_entity({model="grapplinghookrope", x=posx, y=posy, layer=layer, direction=self.d8, width=8, height=8})
			self.ropesprites[i]:start(self.type, self.d16)
		end

		self.ropesprites[i]:set_position(posx, posy)
	end

	for dist, ropesprite in pairs(self.ropesprites) do
		if dist > d-SPACING then
			ropesprite:remove()
			self.ropesprites[dist] = nil
		end
	end

	if self.pulling then
		if self.target:get_distance(self.ability.entitydata.entity) < 30 then
			self.ability:finish()
		end
	end
end

function entity:oncollision(entity2, sprite1, sprite2)
	if sprite1 == self.hooksprite then
		self.ability:attack(entity2, self)
	end
end

function entity:on_removed()
--	self.ticker:remove()

	for dist, ropesprite in pairs(self.ropesprites) do
		ropesprite:remove()
	end
end

local entity = ...

Effects = require "enemies/effect"

function entity:on_created()
end

function entity:start(target)
	self.target = target
	
	self.d4 = self.ability.entitydata.entity:get_direction4_to(self.target.entity)
	self.d8 = self.ability.entitydata.entity:get_direction8_to(self.target.entity)
	
	self.hooksprite = self:create_sprite("abilities/grapplinghook")
	self.hooksprite:set_animation("hook")
	self.hooksprite:set_paused(false)
	self.hooksprite:set_direction(self.d8)
	
	self.ropesprites = {}
	
--	local x, y = self:get_position()
--	local angle = self:get_angle(tox, toy)-- + math.pi
	local movement = sol.movement.create("target")
	movement:set_speed(300)
	movement:set_target(self.target.entity)
--	movement:set_max_distance(dist)
	movement:set_smooth(true)
	movement:start(self)
	function movement.on_finished(movement)
		self.ability:cancel()
	end
	function movement.on_obstacle_reached(movement)
		self.ability:cancel()
	end
	function movement.on_position_changed(movement)
		self:tick()
	end
	
	self:add_collision_test("sprite", self.oncollision)
	
--	self.ticker = Effects.Ticker(self.ability.entitydata, 50, function() self:tick() end)
end

function entity:pull(target)
	self.pulling = true
	self.target = target
	self:clear_collision_tests()
	
	movement = sol.movement.create("target")
	movement:set_speed(300)
	movement:set_target(self.ability.entitydata.entity)
	movement:set_smooth(true)
	movement:start(self)
	function movement.on_position_changed(movement)
		self:tick()
	end
end

SPACING = 20

function entity:tick()
	d = self:get_distance(self.ability.entitydata.entity)
	
	selfx, selfy, layer = self:get_position()
	entityx, entityy = self.ability.entitydata.entity:get_position()
	entityy = entityy - 10
	
	for i = SPACING,d-SPACING,SPACING do
		posx, posy = selfx * (d - i)/d + entityx * i/d,  selfy * (d - i)/d + entityy * i/d
		if self.ropesprites[i] == nil then
			self.ropesprites[i] = map:create_custom_entity({model="grapplinghookrope", x=posx, y=posy, layer=layer, direction=self.d8, width=8, height=8})
			self.ropesprites[i]:setdirection(self.d8)
		end
		
		self.ropesprites[i]:set_position(posx, posy)
	end
	
	for dist, ropesprite in pairs(self.ropesprites) do
		if dist > d then
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
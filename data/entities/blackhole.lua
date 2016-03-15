local entity = ...

Effects = require "enemies/effect"
local math = require "math"

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start()
	self.lightning_sprite = self:create_sprite("abilities/blackhole")
	self.lightning_sprite:set_paused(false)
	
	self.orig_x, self.orig_y = self:get_position()
	
	function self.lightning_sprite.on_animation_finished (sword_sprite, sprite, animation)
		self.ticker:remove()
		self:remove()
	end
	
	self.pulling = {}
	self.collided = {}
	self.particles = {}
	
	for entitydata in self.ability.entitydata:getotherentities() do
		if entitydata.entity:get_distance(self) < 400 then
			if self.ability:catch(entitydata) then 
				self.pulling[entitydata] = true
			
				entitydata.blackholefreeze = Effects.FreezeEffect(entitydata)
			
				entitydata.blackholemovement = sol.movement.create("target")
				entitydata.blackholemovement:set_speed(600)
				entitydata.blackholemovement:set_target(self)
				entitydata.blackholemovement:set_smooth(true)
				entitydata.blackholemovement:start(entitydata.entity)
				function entitydata.blackholemovement.on_finished()
					entitydata.entity:set_visible(false)
					entitydata.stealth = true
				end
			end
		end
	end
	
	self:add_collision_test("sprite", self.oncollision)
	self.ticker = Effects.Ticker(self.ability.entitydata, 100, function() self:tick() end)
	self.timer = Effects.SimpleTimer(self.ability.entitydata, 3000, function() self:finish() end)
end

PARTICLEDIST = 400

function entity:tick()
	x, y = self:get_position()
	for i = 1,math.random(1,3) do
		newx, newy = x + math.random(-PARTICLEDIST, PARTICLEDIST), y + math.random(-PARTICLEDIST, PARTICLEDIST)
		particle = map:create_custom_entity({model="blackholeparticle", x=newx, y=newy, layer=layer, direction=0, width=8, height=8})
		particle:start(self)
		self.particles[particle] = true
	end
end

function entity:finish()
	for entitydata, _ in pairs(self.pulling) do
		if entitydata.entity ~= nil then
			entitydata.blackholemovement:stop()
			entitydata.blackholefreeze:remove()
			entitydata.entity:set_visible(true)
			entitydata.stealth = false
		end
	end
	
	self.ability:uncatch()
	
	for entity, _ in pairs(self.collided) do
		if entity.entitydata ~= nil then
			self.ability:attack(entity, self)
		end
	end
	
	for particle, _ in pairs(self.particles) do
		particle:finishafter()
	end
	
	self.ticker:remove()
	self.timer:stop()
	
	self:remove()
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if self.collided[entity2] == nil then
			self.collided[entity2] = true

--			self.ability:attack(entity2, self)
		end
	end
end

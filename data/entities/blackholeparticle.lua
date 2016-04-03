local entity = ...

local Effects = require "enemies/effect"
local math = require "math"

function entity:on_created()
--	self:set_optimization_distance(0)
end

function entity:start(blackhole)
	self.blackhole = blackhole

	self.blackholesprite = self:create_sprite("abilities/blackholeparticles")
	self.blackholesprite:set_paused(true)
	self.blackholesprite:set_frame(math.random(0,3))

	self.velx = math.random(-2, 2)
	self.vely = math.random(-2, 2)

	self.ticker = Effects.Ticker(self.blackhole.ability.entitydata, 10, function() self:tick() end)
end

local PULL = 50

function entity:tick()
	local x, y = self:get_position()

	local bx, by = self.blackhole:get_position()
	local dist = self:get_distance(self.blackhole)

	bx, by = bx - x, by - y
	bx, by = bx / math.pow(dist, 2) * PULL, by / math.pow(dist, 2) * PULL

	self.velx = self.velx + bx
	self.vely = self.vely + by

	x = x + self.velx
	y = y + self.vely
	self:set_position(x, y)

	if dist < 50 then
		self:finish()
	end
end

function entity:finish()
	self.blackhole.particles[self] = nil
	self:remove()
end

function entity:on_removed()
	if self.ticker ~= nil then
		self.ticker:remove()
	end
end

function entity:finishafter()
	self.endtimer = Effects.SimpleTimer(self.blackhole.ability.entitydata, math.random(1,1000), function() self:remove() end)
end

function entity:on_suspended()
	self:remove()
end

function entity:on_disabled()
	self:remove()
end

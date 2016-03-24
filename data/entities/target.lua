local entity = ...

local Effects = require "enemies/effect"

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start()
	self.sprite = self:create_sprite("hud/target")
	self.sprite:set_paused(false)
	
	self.ticker = Effects.Ticker(self.ability.entitydata, 50, function() self:tick() end)
end

function entity:tick()
	local x, y = self.ability:gettargetpos()
	self:set_position(x, y)
end

function entity:on_removed()
	self.ticker:remove()
end

function entity:lock()
	self.ticker:remove()
	self.sprite:set_animation("locked")
	self.sprite:set_paused(false)
end
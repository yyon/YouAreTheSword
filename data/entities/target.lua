local entity = ...

local Effects = require "enemies/effect"

function entity:on_created()
end

function entity:start()
	self.sprite = self:create_sprite("hud/target")
	self.sprite:set_paused(false)
	
	self.ticker = Effects.Ticker(self.ability.entitydata, 50, function() self:tick() end)
end

function entity:tick()
	self:set_position(self.ability:gettargetpos())
end

function entity:on_removed()
	self.ticker:remove()
end

function entity:lock()
	self.ticker:remove()
	self.sprite:set_animation("locked")
	self.sprite:set_paused(false)
end
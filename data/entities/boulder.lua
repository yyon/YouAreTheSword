local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
	local aspects = {}
	aspects.knockback = 1000
	local damage = 4
	aspects.fire = {damage=0.1, time=2000, timestep=500}
	return damage, aspects
end

function entity:getspritename()
	return "abilities/meteor"
end

function entity:onposchanged()
end

function entity:getspeed()
	return 300
end

function entity:noobstacles()
	return true
end

function entity:onstart()
	sol.audio.play_sound("fireball")
	self.ticker = Effects.Ticker(self.ability.entitydata, 300, function() sol.audio.play_sound("fireball") end)
end

function entity:on_removed()
	self.ticker:remove()
end

local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
	local aspects = {}
	local damage = 0.5
	return damage, aspects
end

function entity:getspritename()
	return "abilities/seed"
end

function entity:getspeed()
	return 1000
end

function entity:onhit()
	self:remove()
end

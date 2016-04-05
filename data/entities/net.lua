local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
	local aspects = {}
	local damage
	aspects.slow = true
	damage = 0
	return damage, aspects
end

function entity:getspritename()
	return "abilities/net"
end

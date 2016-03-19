local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
	local aspects = {}
	aspects.knockback = 100
	local damage
	if self.type == "fast" then
		damage = 1
	elseif self.type == "power" then
		damage = 2
	end
	return damage, aspects
end

function entity:getspritename()
	if self.type == "fast" then
		return "bosses/abilities/catproj"
	elseif self.type == "power" then
		return "bosses/abilities/catproj2"
	end
end

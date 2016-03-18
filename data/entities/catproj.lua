local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
	local aspects = {}
	aspects.knockback = 100
	local damage = 1
	return damage, aspects
end

function entity:getspritename()
	if self.type == "fast" then
		return "bosses/abilities/catproj"
	end
end

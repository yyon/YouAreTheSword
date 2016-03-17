local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
	local aspects = {}
	aspects.knockback = 50
	aspects.fromentity = self
	local damage = self.damage
	return damage, aspects
end

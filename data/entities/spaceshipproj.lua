local entity = ...

Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
	aspects = {}
	aspects.knockback = 50
	aspects.fromentity = self
	damage = self.damage
	return damage, aspects
end

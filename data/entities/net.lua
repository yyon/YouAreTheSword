local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
	local aspects = {}
	local damage
	aspects.slow = {sprite=self.spritename}
	damage = 0
	return damage, aspects
end

function entity:getspritename()
	return "abilities/" .. self.spritename
end

function entity:onhit()
	self:remove()
end

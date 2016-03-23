local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getspritename()
	return "abilities/heart"
end


function entity:isangle()
	return true
end

function entity:doattack(entitydata)
	self.ability:heal(entitydata)
end

function entity:getmaxdist()
	return 300
end

function entity:isfast()
	return true
end
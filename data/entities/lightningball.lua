local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
  local aspects = {}
  aspects.electric=500
  local damage = 0.5
  return damage, aspects
end

function entity:getspritename()
  return "abilities/lightningball"
end

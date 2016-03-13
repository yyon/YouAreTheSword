local entity = ...

Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
  aspects = {}
  aspects.knockback = 100
  damage = 1
  return damage, aspects
end

function entity:getspritename()
  return "abilities/arrow"
end
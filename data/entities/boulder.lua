local entity = ...

Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
  aspects = {}
  aspects.knockback = 1000
  damage = 4
  return damage, aspects
end

function entity:getspritename()
  return "abilities/boulder"
end

function entity:onposchanged()
end

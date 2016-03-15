local entity = ...

Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
  aspects = {}
  aspects.fire = {damage=0.01, time=500, timestep=100}
  aspects.knockback = 50
  aspects.fromentity = self
  damage = 0.5
  return damage, aspects
end

function entity:getspritename()
  return "bosses/abilities/beams"
end

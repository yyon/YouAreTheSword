local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
  local aspects = {}
  aspects.fire = {damage=0.1, time=2000, timestep=500}
  aspects.knockback = 100
  local damage = 0
  return damage, aspects
end

function entity:getspritename()
  return "abilities/fireball"
end

function entity:onposchanged()
  if math.random() < 0.02 then
    local map = self:get_map()
    local x, y, layer = self:get_position()
    local w, h = self:get_size()

    self.smokeentity = map:create_custom_entity({model="smoke", x=x, y=y, layer=layer, direction=0, width=w, height=h})
    self.smokeentity:start(self, self.angle)
  end
end

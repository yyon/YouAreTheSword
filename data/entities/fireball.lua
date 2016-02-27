local entity = ...

Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

function entity:getdamage()
  aspects = {}
  aspects.fire = {damage=0.1, time=2000, timestep=500}
  aspects.knockback = 100
  damage = 1
  return damage, aspects
end

function entity:getspritename()
  return "abilities/fireball"
end

function entity:onposchanged()
  if math.random() < 0.02 then
    map = self:get_map()
    x, y, layer = self:get_position()
    w, h = self:get_size()

    self.smokeentity = map:create_custom_entity({model="smoke", x=x, y=y, layer=layer, direction=0, width=w, height=h})
    self.smokeentity:start(self, self.angle)
  end
end

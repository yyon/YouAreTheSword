local entity = ...

local Effects = require "enemies/effect"

function entity:on_created()
  self:set_optimization_distance(0)
end

function entity:start()
  self.lightning_sprite = self:create_sprite("abilities/lightning")
	self.lightning_sprite:set_paused(false)
  function self.lightning_sprite.on_animation_finished (sword_sprite, sprite, animation)
		self:remove()
	end
end

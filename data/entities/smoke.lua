local entity = ...

function entity:on_created()
  self:set_optimization_distance(0)
end

function entity:start(fireball, angle)
  self.fireball = fireball

  self.sprite = self:create_sprite("abilities/fireball_smoke")
  self.sprite:set_paused(false)

  local movement = sol.movement.create("straight")
  movement:set_speed(100)
  movement:set_angle(angle)
  movement:set_max_distance(100)
  movement:set_smooth(true)
  movement:start(self)

  function movement.on_obstacle_reached(movement)
		self:remove()
	end
	function movement.on_finished(movement)
		self:remove()
	end

  self:set_enabled()
end

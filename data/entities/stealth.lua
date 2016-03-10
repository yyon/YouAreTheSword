local entity = ...

function entity:on_created()
  self:set_optimization_distance(0)
end

function entity:start(ability)
  self.ability = ability

  self.sprite = self:create_sprite("abilities/smokebomb")
  self.sprite:set_paused(true)
  self.sprite:set_frame(math.random(0,3))

  local movement = sol.movement.create("straight")
  movement:set_speed(100)
  angle = math.random() * 2 * math.pi
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

function entity:on_suspended()
	self:remove()
end

function entity:on_disabled()
	self:remove()
end
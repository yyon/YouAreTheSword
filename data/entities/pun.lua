local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start()
	self.blackholesprite = self:create_sprite("bosses/abilities/dunsmurpuns")
	self.blackholesprite:set_paused(true)
	self.blackholesprite:set_frame(math.random(0,5))
	
	local movement = sol.movement.create("straight")
	movement:set_speed(30)
	movement:set_angle(math.random(-0.1, 0.1) + math.pi / 4)
	movement:set_max_distance(90)
	movement:set_ignore_obstacles(true)
	movement:start(self)

	function movement.on_obstacle_reached(movement)
		self:remove()
	end
	function movement.on_finished(movement)
		self:remove()
	end

	self:set_enabled()
end
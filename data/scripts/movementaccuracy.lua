local math = require "math"

function movementaccuracy(movement, angle, entity)
	movement.i = 0
	movement.angle = angle
	movement.entity = entity
	movement.startx, movement.starty = entity:get_position()
	movement.actualposchange = movement.on_position_changed
	movement.actualobstacle = movement.on_obstacle_reached
	movement.lastx, movement.lasty = movement.startx, movement.starty
	
	function movement:on_position_changed()
		self.didpos = true
		self.i = self.i + 1
		if self.i > 10 then
			self.i = 0
			d = self.entity:get_distance(self.startx, self.starty)
			newx, newy = self.startx + math.cos(-self.angle)*d, self.starty + math.sin(-self.angle)*d
			x, y = self.entity:get_position()
			if (math.floor(x) == math.floor(self.lastx) and math.floor(y) == math.floor(self.lasty)) or self.entity:test_obstacles(newx-x, newy-y) then
				if self.actualobstacle ~= nil then
					self:actualobstacle()
				end
			end
			self.lastx, self.lasty = x, y
			self:set_xy(newx, newy)
		else
			if self.actualposchange ~= nil then
				self:actualposchange()
			end
		end
	end
	function movement:on_obstacle_reached()
		if self.didpos then
			self.didpos = false
		else
			if self.actualobstacle ~= nil then
				self:actualobstacle()
			end
		end
			
	end
end

function targetstopper(movement, entity, target)
	movement.actualposchange = movement.on_position_changed
	movement.actualobstacle = movement.on_obstacle_reached
	movement.entity = entity
	movement.thetarget = target
	movement.hitobstacle = false
	
	function movement:on_position_changed()
		angle = self.entity:get_angle(self.thetarget)
		x, y = self.entity:get_position()
		d = 10
		dx, dy = math.cos(-angle)*d, math.sin(-angle)*d
		if self.entity:test_obstacles(dx, dy) then
			if self.hitobstacle then
				if self.actualobstacle ~= nil then
--					print("hit obstacle")
					self:actualobstacle()
				end
			end
			self.hitobstacle = true
		else
			self.hitobstacle = false
		end
		
		if self.actualposchange ~= nil then
			self:actualposchange()
		end
	end
end
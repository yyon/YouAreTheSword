local math = require "math"

function canmoveto(entity, tox, toy)
	local d = entity:get_distance(tox, toy)
	local x, y = entity:get_position()
	local dx, dy = tox-x, toy-y
	local canmove = true
	for i=8,d,8 do
		local p = i/d
		local newdx, newdy = dx*p, dy*p
		if entity:test_obstacles(newdx, newdy) then
			canmove = false

			break
		end
	end

	if entity:test_obstacles(dx, dy) then
		canmove = false
	end

	return canmove
end

local canmoveto = canmoveto

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
			local d = self.entity:get_distance(self.startx, self.starty)
			local newx, newy = self.startx + math.cos(-self.angle)*d, self.starty + math.sin(-self.angle)*d
			local x, y = self.entity:get_position()

			local hitobstacle = false

			if (math.floor(x) == math.floor(self.lastx) and math.floor(y) == math.floor(self.lasty)) or not canmoveto(self.entity, newx, newy) then --self.entity:test_obstacles(newx-x, newy-y) then
				hitobstacle = true
				if self.actualobstacle ~= nil then
					self:actualobstacle()
					self.on_obstacle_reached = nil
				end
			end

			if not hitobstacle then
				self.lastx, self.lasty = x, y
				self:set_xy(newx, newy)
			end
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
				self.on_obstacle_reached = nil
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
		local angle = self.entity:get_angle(self.thetarget)
--		local x, y = self.entity:get_position()
		local d = 10
		local dx, dy = math.cos(-angle)*d, math.sin(-angle)*d
		if self.entity:test_obstacles(dx, dy) then
			if self.hitobstacle then
				if self.actualobstacle ~= nil then
--					print("hit obstacle")
					self:actualobstacle()
					self.on_obstacle_reached = nil
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

return {canmoveto=canmoveto, movementaccuracy=movementaccuracy, targetstopper=targetstopper}

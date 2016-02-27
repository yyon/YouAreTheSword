local entity = ...

function entity:on_created()
end

function entity:start(ability, tox, toy)
  self.ability = ability

  self.sprite = self:create_sprite(self:getspritename())
  self.sprite:set_paused(false)

	local x, y = self:get_position()
	local angle = self:get_angle(tox, toy)-- + math.pi
  self.angle = angle
  local movement = sol.movement.create("straight")
	movement:set_speed(self:getspeed())
	movement:set_angle(angle)
	movement:set_max_distance(self:getmaxdist())
	movement:set_smooth(true)
	movement:start(self)

	function movement.on_position_changed(movement)
    self:onposchanged()
	end
	function movement.on_obstacle_reached(movement)
		self:finish()
	end
	function movement.on_finished(movement)
		self:finish()
	end

  self.collided = {}
	self:add_collision_test("sprite", self.oncollision)
end

function entity:finish()
  self:onfinished()
  self:remove()
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if self.collided[entity2] == nil then
			self.collided[entity2] = true

			self:doattack(entity2.entitydata)
		end
	end
end

function entity:doattack(entitydata)
  damage, aspects = self:getdamage()
  if self.ability.entitydata:cantarget(entitydata) then
    self.ability:dodamage(entitydata, damage, aspects)
  end
end

-- methods to overwrite:

function entity:onfinished()
end

function entity:getspeed()
  return 300
end

function entity:getmaxdist()
  return 300
end

function entity:onposchanged()
end

function entity:getdamage()
  return 1, {}
end

function entity:getspritename()
end

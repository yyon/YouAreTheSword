local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start(appearance, isontop)
	self.isontop = isontop
	
	self.sword_sprite = self:create_sprite(appearance)
	self.sword_sprite:set_paused(false)

--	self.sword_sprite:set_direction(self:get_direction())
	self:updatedirection()

	function self.sword_sprite.on_animation_finished (sword_sprite, sprite, animation)
		self.ability:finish()
	end

	self.collided = {}
	
	if not isontop then
		self:add_collision_test("sprite", self.oncollision)
	end
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if self.collided[entity2] == nil then
			self.collided[entity2] = true

			self.ability:attack(entity2)
		end
	end
end

function entity:updatedirection()
	if self:get_direction() == 3 then
		self:bring_to_front()
		x,y,layer = self:get_position()
		if self.isontop then
			layer = 2
		end
		self:set_position(x,y,layer)
	else
		self:bring_to_back()
		x,y,layer = self:get_position()
		self:set_position(x,y,layer)
	end

	self.sword_sprite:set_direction(self:get_direction())
end

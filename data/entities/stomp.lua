local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start()
	self.sword_sprite = self:create_sprite("abilities/earthquake")
	self.sword_sprite:set_paused(false)
	
	function self.sword_sprite.on_animation_finished (sword_sprite, sprite, animation)
		self.ability:finish()
	end

	self.collided = {}
	
	self:add_collision_test("sprite", self.oncollision)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if self.collided[entity2] == nil then
			self.collided[entity2] = true
			
			self.ability:attack(entity2)
		end
	end
end
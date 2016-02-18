local entity = ...

function entity:on_created()
end

function entity:start()
	self.sword_sprite = self:create_sprite("hero/sword3")
	self.sword_sprite:set_paused(false)
	
	self.sword_sprite:set_direction(self:get_direction())
	
	self.ability.entitydata:setanimation("sword")
	
	function self.sword_sprite.on_animation_finished (sword_sprite, sprite, animation)
		self.ability:finish()
	end
	
	self.collided = {}
	
	self:add_collision_test("sprite", self.oncollision)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if entity2 ~= self.ability.entitydata.entity then
			if self.collided[entity2] == nil then
				self.collided[entity2] = true
				
				self.ability:attack(entity2.entitydata)
			end
		end
	end
end

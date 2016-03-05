local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
	
	self.sprite = self:create_sprite("abilities/teleportanim")
	self.sprite:set_paused(false)
	
	function self.sprite.on_animation_finished (teleportsprite, sprite, animation)
		self:remove()
	end
end

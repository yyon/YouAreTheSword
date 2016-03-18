local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start(appearance, animation)
	self.sword_sprite = self:create_sprite(appearance)
	self.sword_sprite:set_paused(false)

	self.sword_sprite:set_direction(self:get_direction())
	self.sword_sprite:set_animation(animation)

	self.collided = {}

	self:add_collision_test("sprite", self.oncollision)
end

function entity:updatepos()
	local x, y, layer = self.ability.entitydata.entity:get_position()
	self:set_position(x, y, layer)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if self:get_distance(entity2) < 80 then
			if self.collided[entity2] == nil then
				self.collided[entity2] = true

				self.ability:attack(entity2)
			end
		end
	end
end

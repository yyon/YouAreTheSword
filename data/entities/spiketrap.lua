local entity = ...

function entity:on_update()
	self.collided = {}
	self:add_collision_test("touching", self.oncollision)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if not self.collided[entity2] then
			self.collided[entity2] = true
			if self:get_sprite():get_frame() == 2 then
				entity2.entitydata:dodamage(entity2.entitydata, 0.5, {natural = true, fromentity = self})
			end
		end
	end
end
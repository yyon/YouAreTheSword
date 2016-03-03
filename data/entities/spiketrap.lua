local entity = ...

function entity:on_created()
	self:set_layer_independent_collisions([independent])
end

function entity:start()
	self:add_collision_test("sprite", self.oncollision)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if sprite2:get_frame() == 2 then
			entity2.entitydata:dodamage(entity2.entitydata, 1, nil)
		end
	end
end
local entity = ...

function entity:on_update()
	self:add_collision_test("touching", self.oncollision)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		entity2.entitydata:dodamage(entity2.entitydata, 99999, {natural = true, fromentity = true})
	end
end
local entity = ...

function entity:on_update()
	self.collided = {}
	self:add_collision_test("touching", self.oncollision)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if not self.collided[entity2] then
			self.collided[entity2] = true
			entity2.entitydata:dodamage(entity2.entitydata, 0, {instantdeath = true, natural = true, fromentity = self})
		end
	end
end
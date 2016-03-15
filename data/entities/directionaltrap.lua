local entity = ...

function entity:on_created()
	self.collided = {}
	self:add_collision_test("sprite", self.oncollision)
end
function entity:on_update()
	if self:get_sprite():get_frame() == 0 then
		self.collided = {}
	end
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if not self.collided[entity2] then
			if self:get_sprite():get_frame() == 2 then
				self.collided[entity2] = true
				entity2.entitydata:dodamage(entity2.entitydata, 0.5, {sameteam = true, fromentity = self, directionalknockback=true})
			end
		end
	end
end
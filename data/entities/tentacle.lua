local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start()
	self.sprite = self:create_sprite("bosses/abilities/tentacles")
	self.sprite:set_paused(false)

	self:add_collision_test("sprite", self.oncollision)

--	self.timer = Effects.SimpleTimer(self.ability.entitydata, 50000, function() self:remove() end)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		self.ability:attack(entity2)
	end
end

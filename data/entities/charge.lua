local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start(appearance)
	self.sword_sprite = self:create_sprite("abilities/charge")
	self.sword_sprite:set_paused(false)

--	self.sword_sprite:set_animation("")

	self.sword_sprite:set_direction(self:get_direction())

--	self.ability.entitydata:log("charge sword created")

	self.collided = {}

	self:add_collision_test("sprite", self.oncollision)
end

function entity:updatepos()
	local x, y, layer = self.ability.entitydata.entity:get_position()
	self:set_position(x, y, layer)
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if self.collided[entity2] == nil then
			self.collided[entity2] = true

			self.ability:attack(entity2)
		end
	end
end

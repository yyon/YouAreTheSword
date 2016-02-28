local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start(appearance)
	self.sword_sprite = self:create_sprite("adventurers/charge_sword")
	self.sword_sprite:set_paused(false)

--	self.sword_sprite:set_animation("")

	self.sword_sprite:set_direction(self:get_direction())

	self.ability.entitydata:log("charge sword created")
end

function entity:updatepos()
	x, y, layer = self.ability.entitydata.entity:get_position()
	self:set_position(x, y, layer)
end

local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)

	self.ropesprite = self:create_sprite("abilities/grapplinghookrope3")
	self.ropesprite:set_animation("rope")
	self.ropesprite:set_paused(true)
end

function entity:setdirection(d)
--	self.ropesprite:set_direction(d)
	self.ropesprite:set_frame(d)
end

local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:setdirection(d)
end

function entity:start(type, d)
	self.ropesprite = self:create_sprite("abilities/grapplinghookrope3")
	if type == nil then
		self.ropesprite:set_animation("rope")
	elseif type == "vine" then
		self.ropesprite:set_animation("vine")
	end
	self.ropesprite:set_paused(true)
	self.ropesprite:set_frame(d)
end
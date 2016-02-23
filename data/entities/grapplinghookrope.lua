local entity = ...

function entity:on_created()
	self.ropesprite = self:create_sprite("abilities/grapplinghook")
	self.ropesprite:set_animation("longerrope")
end

function entity:setdirection(d)
	self.ropesprite:set_direction(d)
end

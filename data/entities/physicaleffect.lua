local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start(effect, name, time)
	self.effect = effect

	self.sprite = self:create_sprite("physicaleffects/"..name)
	self.sprite:set_paused(false)

	self.sprite:set_direction(0)

--	sol.timer.start(self, time, function() self:finish() end)

--	self:tick()
	self.effect.entitydata.positionlisteners[self] = function(x,y,layer) self:updateposition(x,y,layer) end
end

function entity:cancel()
	self:finish()
end

function entity:updateposition(x, y, layer)
--	entity = self.effect.entitydata.entity

--	x,y,layer = entity:get_position()

	self:set_position(x, y, layer+1)

--	sol.timer.start(self, 100, function() self:tick() end)
end

function entity:finish()
	self.effect.entitydata.positionlisteners[self] = nil
--	sol.timer.stop_all(self)
	self:remove()
end

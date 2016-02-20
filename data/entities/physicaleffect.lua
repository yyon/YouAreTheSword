local entity = ...

function entity:on_created()
end

function entity:start(effect, name, time)
	self.effect = effect
	
	self.sprite = self:create_sprite("physicaleffects/"..name)
	self.sprite:set_paused(false)
	
	self.sprite:set_direction(0)
	
--	sol.timer.start(self, time, function() self:finish() end)
	
	self:tick()
end

function entity:cancel()
	self:finish()
end

function entity:tick()
	entity = self.effect.entitydata.entity
	
	x,y,layer = entity:get_position()
	
	self:set_position(x, y, layer+1)
	
	sol.timer.start(self, 100, function() self:tick() end)
end

function entity:finish()
	sol.timer.stop_all(self)
	self:remove()
end

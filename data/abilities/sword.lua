entitydata = ...

ability = sol.main.load_file("abilities/ability")(entitydata, 25, 0, 0, "sword", 1)

ability.ticking = false

function ability:doability()
	self.entitydata:freeze()
		
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata
	
	d = entitydata:getdirection()
	
	self.swordentity = map:create_custom_entity({model="sword", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.swordentity.ability = self
	
	self.swordentity:start()
end

function ability:cancel()
	self:finish()
end

function ability:finish()
--	self.swordentity.sword_sprite:set_paused(true)
--	self.swordentity:set_visible(false)
	self.swordentity:remove()
	self.swordentity = nil
	self:finishability()
	
	self.entitydata:unfreeze(false)
end

function ability:attack(entitydata)
	self:dodamage(entitydata)
end

return ability
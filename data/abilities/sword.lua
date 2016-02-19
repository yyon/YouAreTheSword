entitydata = ...

ability = sol.main.load_file("abilities/ability")(entitydata, "sword", 25, 0, 0, true)

function ability:doability()
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata
	
	d = entitydata:getdirection()
	
	self.swordentity = map:create_custom_entity({model="sword", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.swordentity.ability = self
	
	self.entitydata:setanimation("sword")
	
	self.swordentity:start(self:get_appearance())
end

function ability:cancel()
	self:finish()
end

function ability:finish()
	self.entitydata:setanimation("walking")
	
	self.swordentity:remove()
	self.swordentity = nil
	self.entitydata:log("sword finish 2")
	self:finishability()
end

function ability:attack(entitydata)
	damage = 1
	aspects = {}
	
	transform = self:gettransform()
	if transform == "ap" then
		aspects.ap = true
	elseif transform == "electric" then
		self.entitydata:log("going to stun")
		aspects.stun = 2000
	elseif transform == "fire" then
		aspects.fire = {damage=0.1, time=5000, timestep=500}
	end
	
	self:dodamage(entitydata, damage, aspects)
end

function ability:gettransform()
	entity = self.entitydata.entity
	if entity.ishero then
		if entity.swordtransform ~= nil then
			return entity.swordtransform
		end
	end
	
	return "normal"
end

function ability:get_appearance()
	transform = self:gettransform()
	
	if transform == "normal" then
		return "hero/sword1"
	elseif transform == "ap" then
		return "hero/sword2"
	elseif transform == "fire" then
		return "hero/sword3"
	elseif transform == "electric" then
		return "hero/sword4"
	else
		self.entitydata:log("Couldn't find appearance!", transform)
	end
end

return ability
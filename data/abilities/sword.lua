local class = require "middleclass"
Ability = require "abilities/ability"

SwordAbility = Ability:subclass("SwordAbility")

function SwordAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "sword", 25, 0, 0, true)
end

function SwordAbility:doability()
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

function SwordAbility:cancel()
	self:finish()
end

function SwordAbility:finish()
	self.entitydata:setanimation("walking")
	
	self.swordentity:remove()
	self.swordentity = nil
	self.entitydata:log("sword finish 2")
	self:finishability()
end

function SwordAbility:attack(entitydata)
	damage = 1
	aspects = {}
	
	transform = self:gettransform()
	if transform == "ap" then
		aspects.ap = true
	elseif transform == "electric" then
		aspects.electric = 2000
	elseif transform == "fire" then
		aspects.fire = {damage=0.1, time=5000, timestep=500}
	end
	
	self:dodamage(entitydata, damage, aspects)
end

function SwordAbility:gettransform(entity)
	if entity == nil then
		entity = self.entitydata.entity
	end
	
	if entity.ishero then
		if entity.swordtransform ~= nil then
			return entity.swordtransform
		end
	end
	
	return "normal"
end

function SwordAbility:get_appearance(entity)
	transform = self:gettransform(entity)
	
	if transform == "normal" then
		return "hero/sword1"
	elseif transform == "ap" then
		return "hero/sword2"
	elseif transform == "fire" then
		return "hero/sword3"
	elseif transform == "electric" then
		return "hero/sword4"
	end
end

return SwordAbility
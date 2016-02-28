local class = require "middleclass"
Ability = require "abilities/ability"

--[[
Effects = require "enemies/effect"
FireEffect = Effects.PhysicalEffect:subclass("SwordSwinging")

function FireEffect:getspritename()
	return "fire"
end

function FireEffect:start(aspect)
	time = aspect.time
	self.firedamage = aspect.damage
	timestep = aspect.timestep

	self:starttick(timestep)

	PhysicalEffect.start(self, time)
end

function FireEffect:tick()
	self.entitydata:dodamage(self.entitydata, self.firedamage, {flame=true, natural=true})
end

function FireEffect:getkey()
	return "FireEffect"
end
--]]

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

	self.entitydata:setanimation("sword")

	self.swordentity = map:create_custom_entity({model="sword", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.swordentity.ability = self
	self.swordentity:start(self:get_appearance())

	self.topsword = map:create_custom_entity({model="sword", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.topsword.ability = self
	self.topsword:start(self:get_appearance(), true)
end

function SwordAbility:onfinish()
	self.entitydata:setanimation("walking")

	self.swordentity:remove()
	self.swordentity = nil
	self.topsword:remove()
	self.topswowrd = nil
	self.entitydata:log("sword finish 2")
	self:finishability()
end

function SwordAbility:attack(entity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	entitydata = entity.entitydata

	damage = 1
	aspects = {}

	transform = self:gettransform()
	if transform == "ap" then
		aspects.ap = true
		aspects.dontblock = true
	elseif transform == "electric" then
		aspects.electric = 2000
	elseif transform == "fire" then
		aspects.fire = {damage=0.1, time=5000, timestep=500}
	elseif transform == "poison" then
		aspects.poison = {weakness=0.1, time=5000}
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
		return "swords/swordanim"
	elseif transform == "ap" then
		return "swords/mace"
	elseif transform == "fire" then
		return "swords/fire"
	elseif transform == "electric" then
		return "swords/electric"
	elseif transform == "poison" then
		return "swords/poison"
	end
end

return SwordAbility

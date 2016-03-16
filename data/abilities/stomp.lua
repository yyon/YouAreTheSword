local class = require "middleclass"
Ability = require "abilities/ability"

StompAbility = Ability:subclass("StompAbility")

local Effects = require "enemies/effect"

function StompAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Stomp", 1000, "stomp", 500, 10000, true, "stomp")
end

function StompAbility:doability()
	self.entitydata:setanimation("stomp2")
	
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	self.stompentity = map:create_custom_entity({model="stomp", x=x, y=y, layer=layer, direction=0, width=w, height=h})
	self.stompentity.ability = self
	self.stompentity:start()
	
	sol.audio.play_sound("stomp")
end

function StompAbility:onfinish()
end

function StompAbility:attack(entity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end
	
	entitydata = entity.entitydata

	damage = 3
	aspects = {knockback=1000}

	self:dodamage(entitydata, damage, aspects)
end

return StompAbility

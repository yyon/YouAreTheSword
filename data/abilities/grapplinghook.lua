local class = require "middleclass"
Ability = require "abilities/ability"

Effects = require "enemies/effect"

require "scripts/movementaccuracy"

GrapplingHookAbility = Ability:subclass("GrapplingHookAbility")

function GrapplingHookAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Grappling Hook", 800, "grapplinghook", 500, 2000, true)
end

function GrapplingHookAbility:doability(tox, toy)
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	d = 0

	target = self.entitydata:getclosestentity(tox, toy, true)
--	self.entitydata:log("recieved target,", tox, toy, target.team)
	if target == nil then
		self:finish()
		return
	end

	self.hookentity = map:create_custom_entity({model="grapplinghook", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.hookentity.ability = self

	self.hookentity:start(target)

	self.timer = Effects.SimpleTimer(self.entitydata, 5000, function() self:timeend() end)
end

function GrapplingHookAbility:oncancel()
	self:stoppulling(true)
end

function GrapplingHookAbility:onfinish()
	self:stoppulling()
end

function GrapplingHookAbility:goback()
end

function GrapplingHookAbility:attack(entity, bombentity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	self.target = entity.entitydata
	

	self:dodamage(entity.entitydata, 0, {knockback=0, method=function() self:startpull() end})
end

function GrapplingHookAbility:startpull()
	if not self:catch(self.target) then return end
	
	self.timer:stop()
	self.timer = Effects.SimpleTimer(self.entitydata, 5000, function() self:timeend() end)

	self.freeze = Effects.FreezeEffect(self.target)
	self.hookentity:pull(self.target.entity)

	self.movement = sol.movement.create("target")
	self.movement:set_speed(600)
	self.movement:set_target(self.entitydata.entity)
	self.movement:start(self.hookentity.target)
	
	function self.movement.on_obstacle_reached(movement, stuff)
		self:finish()
	end
	
	targetstopper(self.movement, self.hookentity.target, self.entitydata.entity)
end

function GrapplingHookAbility:timeend()
	self:cancel()
end

function GrapplingHookAbility:stoppulling(canceled)
	if self.hookentity ~= nil then
		self.timer:stop()
		self.hookentity:remove()
	end

	if self.target ~= nil then
		if self.movement ~= nil then
			self.movement:stop()
		end
		if self.freeze ~= nil then
			self.freeze:remove()
		end
		
		if not canceled then
			damage = 0
			aspects = {stun=500, knockback=0}

			self:dodamage(self.target, damage, aspects)
		end
	end
end

return GrapplingHookAbility

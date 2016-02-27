local class = require "middleclass"
Ability = require "abilities/ability"

Effects = require "enemies/effect"

GrapplingHookAbility = Ability:subclass("GrapplingHookAbility")

RANGE = 400

function GrapplingHookAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "grappling hook", RANGE, 500, 10000, true)
end

function GrapplingHookAbility:doability(tox, toy)
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	d = 0

	target = self.entitydata:getclosestentity(tox, toy)
	self.entitydata:log("recieved target,", tox, toy, target.team)
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
	self.timer:stop()
	self.timer = Effects.SimpleTimer(self.entitydata, 5000, function() self:timeend() end)

	self.freeze = Effects.FreezeEffect(self.target)
	self.hookentity:pull(self.target.entity)

	self.movement = sol.movement.create("target")
	self.movement:set_speed(300)
	self.movement:set_target(self.entitydata.entity)
	self.movement:set_smooth(true)
	self.movement:start(self.hookentity.target)
end

function GrapplingHookAbility:timeend()
	self:cancel()
end

function GrapplingHookAbility:stoppulling(canceled)
	if self.hookentity ~= nil then
		self.timer:stop()
		self.hookentity:remove()
	end

	if self.target ~= nil and not canceled then
		self.movement:stop()
		self.freeze:remove()

		damage = 0
		aspects = {stun=500, knockback=0}

		self:dodamage(self.target, damage, aspects)
	end
end

return GrapplingHookAbility

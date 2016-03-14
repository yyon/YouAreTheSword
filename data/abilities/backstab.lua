local class = require "middleclass"
Ability = require "abilities/ability"
require "scripts/movementaccuracy"

SwordAbility = require "abilities/sword"

local math = require "math"

BackstabAbility = Ability:subclass("BackstabAbility")

function BackstabAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Backstab", 800, "backstab", 0, 1000, true)
end

function BackstabAbility:doability(tox, toy)
	tox, toy = self.entitydata:gettargetpos()
	self.target = self.entitydata:getclosestentity(tox, toy)
	
	self.target.entity.cantrotate = true
	
	self.d = self.entitydata.entity:get_distance(self.target.entity)
	targetd = 40
	
	time = 200
	tickstep = 10
	self.step = time/tickstep
	
--	self:dodamage(self.target, 0, {knockback=0, stun=time+100})
	
	self.dd = (self.d - targetd) / self.step
	self.angle = self.target.entity:get_angle(self.entitydata.entity)

	self.timer = Effects.SimpleTimer(self.entitydata, time, function() self:dofinish() end)
	self.ticker = Effects.Ticker(self.entitydata, tickstep, function() self:dotick() end)
end

function BackstabAbility:dotick()
	self.angle = self.angle + math.pi / self.step
	self.d = self.d - self.dd
	x, y = self.target.entity:get_position()
	x, y = x + math.cos(self.angle)*self.d, y - math.sin(self.angle)*self.d
	self.entitydata.entity:set_position(x, y)
end

function BackstabAbility:dofinish()
	self.ticker:remove()
	self.timer:stop()
	
	self:finish()
	
	self.entitydata:setdirection(self.entitydata.entity:get_direction4_to(self.target.entity))
	self.entitydata:startability("normal")
end

function BackstabAbility:onfinish()
	self.entitydata.entity:stop_movement()
	
	self.target.entity.cantrotate = nil
	
	self.ticker:remove()
	self.timer:stop()
end

return BackstabAbility

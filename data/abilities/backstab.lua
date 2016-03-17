local class = require "middleclass"
local Ability = require "abilities/ability"
require "scripts/movementaccuracy"

local Effects = require "enemies/effect"
local SwordAbility = require "abilities/sword"

local math = require "math"

local BackstabAbility = Ability:subclass("BackstabAbility")

function BackstabAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Backstab", 800, "backstab", 0, 3000, true)
end

function BackstabAbility:doability()
	local tox, toy = self.entitydata:gettargetpos()
	self.target = self.entitydata:getclosestentity(tox, toy, true)
--	if self.target == nil then
--		self:finish(true)
--		return
--	end

	if not self:catch(self.target) then return end

	self.target.entity.cantrotate = true

	self.d = self.entitydata.entity:get_distance(self.target.entity)
	local targetd = 40

	local time = 200
	local tickstep = 10
	self.step = time/tickstep

--	self:dodamage(self.target, 0, {knockback=0, stun=time+100})

	self.dd = (self.d - targetd) / self.step
	self.angle = self.target.entity:get_angle(self.entitydata.entity)

	self.timer = Effects.SimpleTimer(self.entitydata, time, function() self:dofinish() end)
	self.ticker = Effects.Ticker(self.entitydata, tickstep, function() self:dotick() end)

	sol.audio.play_sound("swing" .. math.random(1,3))
end

function BackstabAbility:dotick()
	if self.target.entity == nil then
		self:cancel()
	else
		self.angle = self.angle + math.pi / self.step
		self.d = self.d - self.dd
		local x, y = self.target.entity:get_position()
		x, y = x + math.cos(self.angle)*self.d, y - math.sin(self.angle)*self.d

		local canmoveto = self.entitydata:canmoveto(x, y)
		if not canmoveto then
			self:finish(true)
		else
			self.entitydata.entity:set_position(x, y)
		end
	end
end

function BackstabAbility:dofinish()
	self.ticker:remove()
	self.timer:stop()

	self:finish()

	if self.target.entity ~= nil then
		self.entitydata:setdirection(self.entitydata.entity:get_direction4_to(self.target.entity))
		self.entitydata:startability("normal")
	end
end

function BackstabAbility:onfinish()
	self.entitydata.entity:stop_movement()

	if self.target.entity ~= nil then
		self.target.entity.cantrotate = nil
	end

	self.ticker:remove()
	self.timer:stop()
end

return BackstabAbility

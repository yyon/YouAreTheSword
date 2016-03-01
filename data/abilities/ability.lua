local class = require "middleclass"

Ability = class("Ability")
Effects = require "enemies/effect"

local math = require "math"

function Ability:initialize(...)
	self.entitydata, self.name, self.range, self.warmup, self.cooldown, self.dofreeze = ...
	self.canuse = true
end

function Ability:start(...)
	self.entitydata.usingability = self
	if self.dofreeze then
--		self.entitydata:freeze(self.name, 1, function() self:cancel() end)
		self.freezeeffect = Effects.FreezeEffect(self.entitydata)
	end
	self.canuse = false
	self.args = {...}
	self.warmuptimer = Effects.SimpleTimer(self.entitydata, self.warmup * self.entitydata.stats.warmup, function() self:finishwarmup() end)
	
	if self.entitydata.entity.ishero then
		-- Add HUD call here
		-- Hud:StartAbilityUsed(self)
	end
end

function Ability:finishwarmup()
	self.usingability = true
	self:doability(unpack(self.args))
end

COOLDOWNTICKTIME = 50

function Ability:finishability()
	self.entitydata:log("ability finish")
	self.entitydata.usingability = nil
	if self.warmuptimer ~= nil then
		self.warmuptimer:stop()
	end
	if self.dofreeze then
		self.entitydata:log("unfreeze", self.name)
		self.freezeeffect:remove()
--		self.entitydata:unfreeze(self.name, false)
	end
	self.usingability = false
	
	if self.entitydata.entity.ishero then
		-- Add HUD call here
		-- Hud:StartCooldown(self)
	
		self.cooldowntimetracker = 0
		self.cooldownticker = Effects.Ticker(self.entitydata, COOLDOWNTICKTIME, function() self:cooldowntick() end)
	end
	
	self.cooldowntimer = Effects.SimpleTimer(self.entitydata, self.cooldown * self.entitydata.stats.cooldown, function() self:finishcooldown() end)
end

function Ability:finishcooldown()
	self.canuse = true
	
	if self.entitydata.entity.ishero then
		self.cooldownticker:remove()
	
		-- Add HUD call here
		-- Hud:EndCooldown(self)
	end
end

function Ability:cooldowntick()
	self.cooldowntimetracker = self.cooldowntimetracker + COOLDOWNTICKTIME
	fraction = self.cooldowntimetracker / self.cooldown
	timeremaining = math.floor((self.cooldown - self.cooldowntimetracker) / 1000)
	print(fraction, timeremaining)
	
	-- Add HUD call here
	-- Hud:UpdateCooldown(self, fraction, timeremaining)
end

function Ability:dodamage(entitydata, damage, aspects)
	if self.entitydata:cantarget(entitydata) then
		self.entitydata:dodamage(entitydata, damage, aspects)
	end
end

function Ability:doability()
	print("WARNING! a blank ability was called")
	self:finish()
end
function Ability:cancel()
	if self.usingability then
		self.entitydata:log("Ability canceled:", self.name)
		self:oncancel()
		self:finishability()
--		self.cooldowntimer:remove()
	end
end
function Ability:finish()
	if self.usingability then
		self:onfinish()
		self:finishability()
	end
end
function Ability:onfinish()
end
function Ability:oncancel()
	self:onfinish()
end

function Ability:tick(...)
end
function Ability:blockdamage(fromentity, damage, aspects)
	return damage, aspects
end

function Ability:AOE(distance, damage, aspects, fromentity)
	if fromentity == nil then
		fromentity = self.entitydata.entity
	else
		aspects.fromentity = fromentity
	end

	for entitydata in self.entitydata:getotherentities() do
		d = fromentity:get_distance(entitydata.entity)
		if d < distance then
			self:dodamage(entitydata, damage, aspects)
		end
	end
end

function Ability:keyrelease()
end

return Ability

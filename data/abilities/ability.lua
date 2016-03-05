local class = require "middleclass"

Ability = class("Ability")
Effects = require "enemies/effect"

local math = require "math"

function Ability:initialize(...)
	-- called when entitydata is first created
	self.entitydata, self.name, self.range, self.warmup, self.cooldown, self.dofreeze, self.warmupanimation = ...
	self.canuse = true
end

function Ability:start(...)
	-- call this to use the ability
	
	self.entitydata.usingability = self
	if self.dofreeze then
--		self.entitydata:freeze(self.name, 1, function() self:cancel() end)
		self.freezeeffect = Effects.FreezeEffect(self.entitydata)
	end
	self.canuse = false
	self.args = {...}
	self.usingwarmup=true
	self.warmuptimer = Effects.SimpleTimer(self.entitydata, self.warmup * self.entitydata.stats.warmup, function() self:finishwarmup() end)
	
	if self.warmupanimation ~= nil and self.warmup ~= 0 then
		self.entitydata:setanimation(self.warmupanimation)
	end
	
	if self.entitydata.entity.ishero then
		-- Add HUD call here
		-- Hud:StartAbilityUsed(self)
	end
end

function Ability:finishwarmup()
	self.usingwarmup=false
	-- once the warmup timer is finished, actually uses the ability
	if self.warmupanimation ~= nil and self.warmup ~= 0 then
		self.entitydata:setanimation("stopped")
	end
	
	self.usingability = true
	self:doability(unpack(self.args))
end

COOLDOWNTICKTIME = 50

function Ability:finishability(skipcooldown)
	-- cleans up the ability to be able to use it again
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
	
	if skipcooldown then
		self:finishcooldown()
	else
		if self.entitydata.entity.ishero then
			-- Add HUD call here
			-- Hud:StartCooldown(self)
		end
	
		self.cooldowntimer = Effects.SimpleTimer(self.entitydata, self.cooldown * self.entitydata.stats.cooldown, function() self:finishcooldown() end)
	end
end

function Ability:finishcooldown()
	self.entitydata:log("Ability", self.name, "finished cooldown")
	
	-- sets the ability to be able to be used again after the cooldown
	self.canuse = true
	
	if self.entitydata.entity.is_hero then
		-- Add HUD call here
		-- Hud:EndCooldown(self)
	end
end

function Ability:getremainingcooldown()
	if self.cooldowntimer == nil then
		return nil
	end
	
	timeremaining = self.cooldowntimer:getremainingtime()
	fraction = 1 - timeremaining / self.cooldown
--	timeremaining = math.floor((self.cooldown - self.cooldowntimetracker) / 1000)
--	print(fraction, timeremaining)
	return fraction, timeremaining
end
function Ability:tick(...)
	-- You should probably use Effects:Ticker instead of this
end

-- functions you can call
function Ability:finish(skipcooldown)
	-- call to finish using ability. You must do this at some point.
	if self.usingability then
		self:onfinish()
		self:finishability(skipcooldown)
	end
end

function Ability:cancel()
	-- call this to cancel the ability. Rarely used.
	if self.usingability then
		self.entitydata:log("Ability canceled:", self.name)
		self:oncancel()
		self:finishability()
--		self.cooldowntimer:remove()
	elseif self.usingwarmup then
		self.usingwarmup = false
		self.warmuptimer:stop()
		self.canuse = true
	end
end

function Ability:AOE(distance, damage, aspects, fromentity)
	-- damage all people a certain distance from something.
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


function Ability:dodamage(entitydata, damage, aspects)
	-- check if you can attack someone, then attack them
	if self.entitydata:cantarget(entitydata) then
		self.entitydata:dodamage(entitydata, damage, aspects)
	end
end

function Ability:withinrange(tox, toy)
	if self.entitydata.entity:get_distance(tox, toy) > self.range then
		x, y = self.entitydata.entity:get_position()
		d = self.entitydata.entity:get_distance(tox, toy)
		vx, vy = tox - x, toy - y
		vx, vy = vx / d * self.range, vy / d * self.range
		tox, toy = x + vx, y + vy
	end
	
	return tox, toy
end

-- functions you can overwrite

function Ability:doability()
	-- called when ability is used
	print("WARNING! a blank ability was called")
	self:finish()
end
function Ability:onfinish()
	-- called when ability is finished (when ability:finish() is called)
end
function Ability:oncancel()
	-- called when ability is canceled in the middle of using it (for example, when user is damaged by another attack)
	self:onfinish()
end
function Ability:keyrelease()
	-- called when the keyboard key used to call this ability is released (does not work for mouse buttons currently)
end
function Ability:blockdamage(fromentity, damage, aspects)
	-- if user is damaged while using this ability, the damage can be modified
	return damage, aspects
end


return Ability

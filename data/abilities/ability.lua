local class = require "middleclass"

local Ability = class("Ability")
local Effects = require "enemies/effect"

local math = require "math"

function Ability:initialize(...)
	if self.caughtduringabilityuse == nil then
		self.caughtduringabilityuse = true
	end
	-- called when entitydata is first created
	self.entitydata, self.name, self.range, self.icon, self.warmup, self.cooldown, self.dofreeze, self.warmupanimation = ...
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
	self.caughttargets = {}
	self.uncatched = false
	self.inability = false
	self.finisheddoability = false

	self:starttarget()

	self.warmuptimer = Effects.SimpleTimer(self.entitydata, self.warmup * self.entitydata.stats.warmup, function() self:finishwarmup() end)

	if self.warmupanimation ~= nil and self.warmup ~= 0 then
		self.entitydata:setanimation(self.warmupanimation)
	end
end

function Ability:finishwarmup()
	if self.entitydata.entity == nil then return end

	self:finishtarget()

	self.usingwarmup=false
	self.inability = true
	-- once the warmup timer is finished, actually uses the ability
	if self.warmupanimation ~= nil and self.warmup ~= 0 then
		self.entitydata:setanimation("stopped")
	end

	self.usingability = true
	local status, err = xpcall(function() self:doability(unpack(self.args)) end, function() print(debug.traceback()) end)
	if status then
		-- no errors
		self.finisheddoability = true
	else
		print("ERROR in calling ability!", self.name)
		print(status, err)
		self:remove()
	end
end

function Ability:starttarget()
	self.targetx, self.targety = self.entitydata:gettargetpos()
	self.origentity = self.entitydata.entity
	self.targetlocked = false
	
	if self.entitydata.entity.ishero and self.warmup ~= 0 then
		local entity = self.entitydata.entity
		local map = entity:get_map()

		self.targetentity = map:create_custom_entity({model="target", x=self.targetx, y=self.targety, direction=0, layer=2, width=24, height=24})
		self.targetentity.ability = self
		self.targetentity:start()
	end
end
function Ability:finishtarget()
	if self.targetentity ~= nil then
		self.targetentity:remove()
		self.targetentity = nil
	end
end
function Ability:gettargetpos()
	if not self.targetlocked and (self.origentity == self.entitydata.entity or self.entitydata.entity.ishero) then
		self.targetx, self.targety = self.entitydata:gettargetpos()
	end
	return self.targetx, self.targety
end
function Ability:locktarget()
	if not self.targetlocked then
		self.targetx, self.targety = self:gettargetpos()
		self.targetlocked = true
		if self.targetentity ~= nil then
			self.targetentity:lock()
		end
	end
end

local COOLDOWNTICKTIME = 50

function Ability:finishability(skipcooldown)
	-- cleans up the ability to be able to use it again
	if self.caughtduringabilityuse then
		self:uncatch()
	end

	self.inability = false
	self.entitydata.usingability = nil
	if self.warmuptimer ~= nil then
		self.warmuptimer:stop()
	end
	if self.dofreeze then
--		self.entitydata:log("unfreeze", self.name)
		self.freezeeffect:remove()
--		self.entitydata:unfreeze(self.name, false)
	end
	self.usingability = false

	self.usingcooldown = true

	if skipcooldown or game.nocooldown then
		self:finishcooldown(skipcooldown)
	else
		self.cooldowntimer = Effects.SimpleTimer(self.entitydata, self.cooldown * self.entitydata.stats.cooldown, function() self:finishcooldown() end)
	end
end

function Ability:finishcooldown(skipcooldown)
--	self.entitydata:log("Ability", self.name, "finished cooldown")
	if self.entitydata.entity == nil then return end

	self.usingcooldown = false

	-- sets the ability to be able to be used again after the cooldown
	self.canuse = true

	if not self.entitydata.entity.ishero and not skipcooldown then
		self.entitydata.entity:tick()
	end
end

function Ability:getremainingcooldown()
	if self.cooldowntimer == nil then
		return nil
	end

	local timeremaining = self.cooldowntimer:getremainingtime()
	local fraction = 1 - timeremaining / self.cooldown
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
	if not self.finisheddoability then
		if self.usingwarmup then
			self.usingwarmup = false
			self.warmuptimer:stop()
		end
		self.canuse = true
		self:finishability(true)
	elseif self.inability then
--		self.entitydata:log("Ability canceled:", self.name)
		self:oncancel()
		self:finishability(false)
--		self.cooldowntimer:remove()
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
		local d = fromentity:get_distance(entitydata.entity)
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
	if self.entitydata.entity ~= nil then
		if self.entitydata.entity:get_distance(tox, toy) > self.range then
			local x, y = self.entitydata.entity:get_position()
			local d = self.entitydata.entity:get_distance(tox, toy)
			local vx, vy = tox - x, toy - y
			vx, vy = vx / d * self.range, vy / d * self.range
			tox, toy = x + vx, y + vy
		end
	end

	return tox, toy
end

function Ability:catch(target, dontend)
	if target == nil or target.caught or target.isbeingknockedback then
		if dontend then
			return false
		else
			self:cancel()
			return false
		end
	else
		self.caughttargets[target] = true
		target.caught = true
		return true
	end
end

function Ability:uncatch()
	if self.uncatched then
		print("ERROR! double uncatch!", self.name)
		print(debug.traceback())
	end
	self.uncatched = true
	for entitydata, b in pairs(self.caughttargets) do
		entitydata.caught = false
	end
	self.caughttargets = {}
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

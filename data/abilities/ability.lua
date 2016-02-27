local class = require "middleclass"

Ability = class("Ability")
Effects = require "enemies/effect"

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
	self.usingability = true
	self:doability(...)
end

function Ability:finishability()
	self.entitydata:log("ability finish")
	self.entitydata.usingability = nil
	if self.dofreeze then
		self.entitydata:log("unfreeze", self.name)
		self.freezeeffect:remove()
--		self.entitydata:unfreeze(self.name, false)
	end
	self.usingability = false
	self.canuse = true
end

function Ability:dodamage(entitydata, damage, aspects)
	self.entitydata:dodamage(entitydata, damage, aspects)
end

function Ability:doability()
	print("WARNING! a blank ability was called")
	self:finish()
end
function Ability:cancel()
	if self.usingability then
		self.entitydata:log("Ability canceled:", self.name)
		print(debug.traceback())
		self:oncancel()
		self:finishability()
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

return Ability

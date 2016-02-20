local class = require "middleclass"

Ability = class("Ability")

function Ability:initialize(...)
	self.entitydata, self.name, self.range, self.warmup, self.cooldown, self.dofreeze = ...
end

function Ability:start()
	self.entitydata.usingability = self
	if self.dofreeze then
		self.entitydata:freeze(self.name, 1, function() self:cancel() end)
	end
	self:doability()
end

function Ability:finishability()
	self.entitydata:log("ability finish")
	self.entitydata.usingability = nil
	if self.dofreeze then
		self.entitydata:log("unfreeze", self.name)
		self.entitydata:unfreeze(self.name, false)
	end
end

function Ability:dodamage(entitydata, damage, aspects)
	self.entitydata:dodamage(entitydata, damage, aspects)
end

return Ability
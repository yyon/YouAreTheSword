ability = {}

ability.entitydata, ability.name, ability.range, ability.warmup, ability.cooldown, ability.dofreeze = ...

function ability:start()
	self.entitydata.usingability = self
	if self.dofreeze then
		self.entitydata:freeze(self.name, 1, function() self:cancel() end)
	end
	self:doability()
end

function ability:finishability()
	self.entitydata:log("ability finish")
	self.entitydata.usingability = nil
	if self.dofreeze then
		self.entitydata:log("unfreeze", self.name)
		self.entitydata:unfreeze(self.name, false)
	end
end

function ability:dodamage(entitydata, damage, aspects)
	self.entitydata:dodamage(entitydata, damage, aspects)
end

return ability
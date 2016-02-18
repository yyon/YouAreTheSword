ability = {}

ability.entitydata, ability.range, ability.warmup, ability.cooldown, ability.entityname, ability.damage = ...

function ability:start()
	self.entitydata.usingability = self
	self:doability()
end

function ability:finishability()
	self.entitydata.usingability = nil
end

function ability:dodamage(entitydata)
	damage = self.damage
	self.entitydata:dodamage(entitydata, damage)
end

return ability
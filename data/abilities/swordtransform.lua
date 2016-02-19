entitydata, transform = ...

ability = sol.main.load_file("abilities/ability")(entitydata, "transform", 0, 1000, 3000, true)

ability.transform = transform

function ability:doability()
	self.entitydata.entity.swordtransform = self.transform
	
	self:finish()
end

function ability:cancel()
	self:finish()
end

function ability:finish()
	self:finishability()
end

return ability
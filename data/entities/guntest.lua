local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:test(tox, toy)
	canshoot = self:dotest(tox, toy)
	self:remove()
	return canshoot
end


function entity:dotest(tox, toy)
	entity = self
	
	local d = entity:get_distance(tox, toy)
	local x, y = entity:get_position()
	local dx, dy = tox-x, toy-y
	canmove = true
	for i=0,2000,20 do
		local p = i/d
		newdx, newdy = dx*p, dy*p
		self:set_position(x+newdx, y+newdy)
		for entitydata in self.ability.entitydata:getotherentities() do
			if self:overlaps(entitydata.entity) then
				return entitydata
			end
		end
	end
	
	return nil
end

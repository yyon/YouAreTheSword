local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
	
	self.isdoor = true
	self.openedby = {}
	self.reversed = self:get_name():match(".*inv.*") ~= nil
	self:set_optimization_distance(0)
	self.sprite = self:create_sprite("Traps/door")
	self:close()
end

function entity:open(lever)
	if lever ~= nil then
		self.openedby[lever] = true
	end

	if not self.reversed then
		self:actuallyopen()
	else
		self:actuallyclose()
	end
end

function entity:actuallyopen()
	self.sprite:set_animation("open")
	self:set_traversable_by(true)
end

function entity:close(lever)
	if lever ~= nil then
		self.openedby[lever] = nil
		local stillopen = false
		for lever, opened in pairs(self.openedby) do
			if opened then stillopen = true end
		end
	end
	
	if not stillopen then
		if not self.reversed then
			self:actuallyclose()
		else
			self:actuallyopen()
		end
	end
end

function entity:actuallyclose()
	self.sprite:set_animation("closed")
	self:set_traversable_by(false)
	
	local map = self:get_map()
	self:testcollide(map:get_hero())
	for entity in map:get_entities("") do
		if entity ~= self then
			self:testcollide(entity)
		end
	end
end

function entity:testcollide(entity)
	if entity:overlaps(self) then
		local x, y = entity:get_position()
		local selfx, selfy = self:get_position()
		entity:set_position(x, selfy + 70)
	end
end

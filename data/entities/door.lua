local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
	self.sprite = self:create_sprite("Traps/door")
	self:close()
end

function entity:open()
	self.sprite:set_animation("open")
	self:set_traversable_by(true)
end

function entity:close()
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

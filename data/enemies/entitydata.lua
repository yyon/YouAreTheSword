entitydata = {}

function entitydata:new(entity, main_sprite, life)
	self.entity = entity
	self.main_sprite = main_sprite
	self.life = life
end

function entitydata:createfromclass(entity, class)
	if class == "purple" then
		self:new(entity, "hero/tunic3", 5)
	end
end

return entitydata
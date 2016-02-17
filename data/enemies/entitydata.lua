entitydata = {}

function entitydata:new(entity, main_sprite, life)
	self.entity = entity
	self.main_sprite = main_sprite
	self.life = life
end

return entitydata
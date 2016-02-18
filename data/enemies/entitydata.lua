entitydata = {}

function entitydata:new(entity, main_sprite, life, team)
	self.entity = entity
	self.main_sprite = main_sprite
	self.life = life
	self.team = team
end

function entitydata:createfromclass(entity, class)
	if class == "purple" then
		self:new(entity, "hero/tunic3", 5, "purple")
	elseif class == "green" then
		self:new(entity, "hero/tunic1", 5, "green")
	else
		print("ERROR! no such class")
	end
end

function entitydata:applytoentity()
	self.entity.entitydata = self
	
	if self.entity.ishero then
		self.entity:set_tunic_sprite_id(self.main_sprite)
	else
		self.entity:load_entitydata()
	end
end

function entitydata:bepossessedbyhero()
	map = self.entity:get_map()
	hero = map:get_hero()
	
	hero:set_position(entity:get_position())
	hero:set_direction(entity.direction)
		
	hero.entitydata = self
	
	self.entity:remove()
	
	self.entity = hero
	self:applytoentity()
	
	self.entity.is_possessing = true
end

function entitydata:unpossess()
	self.entity.is_possessing = false
	
	map = self.entity:get_map()
	
	x, y, layer = self.entity:get_position()
	
	d = self.entity:get_direction()
	
	newentity = map:create_enemy({
		breed="enemy_constructor",
		layer=layer,
		x=x,
		y=y,
		direction=d
	})
	
	self.entity = newentity
	self:applytoentity()
	
	self.entity:setdirection(d)
end

function entitydata:isvisible()
	if self.entity.ishero and not self.entity.is_possessing then
		return false
	end
	return true
end

return entitydata
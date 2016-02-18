entitydata = {}

function entitydata:new(entity, main_sprite, life, team, swordability)
	self.entity = entity
	self.main_sprite = main_sprite
	self.life = life
	self.team = team
	self.swordability = swordability
end

function entitydata:createfromclass(entity, class)
	if class == "purple" then
		self:new(entity, "hero/tunic3", 10, "purple", sol.main.load_file("abilities/sword")(self))
	elseif class == "green" then
		self:new(entity, "hero/tunic1", 10, "green", sol.main.load_file("abilities/sword")(self))
	elseif class == "yellow" then
		self:new(entity, "hero/tunic2", 10, "yellow", sol.main.load_file("abilities/sword")(self))
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
	if self.usingability ~= nil then
		self.usingability:cancel()
	end
	
	hero:unfreeze()
	hero.isdropped = false
	hero.isthrown = false
	
	map = self.entity:get_map()
	hero = map:get_hero()
	
	hero.entitydata = self
	
	hero:set_position(self.entity:get_position())
	hero:set_direction(self.entity.direction)
		
	self.entity:remove()
	
	self.entity = hero
	self:applytoentity()
	
	self.entity.is_possessing = true
end

function entitydata:unpossess()
	self.entity.is_possessing = false
	
	hero = map:get_hero()
	hero.entitydata = nil
	
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
	
	return self.entity
end



function entitydata:isvisible()
	if self.entity.ishero and not self.entity.is_possessing then
		return false
	end
	return true
end

function entitydata:getability(ability)
	if ability == "sword" then
		return self.swordability
	end
end

function entitydata:startability(ability)
	if self.usingability == nil then
		ability = self:getability(ability)
		ability:start()
	end
end

function entitydata:withinrange(ability, entitydata)
	ability = self:getability(ability)
	range = ability.range
	d = self.entity:get_distance(entitydata.entity)
	withinrange = (d <= range)
	return withinrange
end	

function entitydata:getdirection()
	if self.entity.ishero then
		return self.entity:get_direction()
	else
		return self.entity.direction
	end
end

function entitydata:setanimation(anim)
	if self.entity.ishero then
		self.entity:set_animation(anim)
	else
		self.entity.main_sprite:set_animation(anim)
		self.entity.main_sprite:set_paused(false)
	end
end

function entitydata:freeze()
	if self.entity.ishero then
		self.entity:freeze()
	else
		self.entity:tick("frozen")
	end
end

function entitydata:unfreeze(dotick)
	if dotick == nil then dotick = true end
	if self.entity.ishero then
		self.entity:unfreeze()
	else
		self.entity.state = nil
		if dotick then
			self.entity:tick()
		end
	end
end

function entitydata:dodamage(target, damage)
	target.life = target.life - damage
	
	print(target.team, "damaged", damage, "life", target.life)
	
	--aggro
	if not target.entity.ishero then
		target.entity.entitytoattack = self
	end
	
	--cancel enemy's ability
	if target.usingability ~= nil then
		target.usingability:cancel()
	end
	
	--knockback
	if target.entity.ishero then
		target:freeze()
		local x, y = target.entity:get_position()
		local angle = target.entity:get_angle(self.entity) + math.pi
		local movement = sol.movement.create("straight")
		movement:set_speed(128)
		movement:set_angle(angle)
		movement:set_max_distance(26)
		movement:set_smooth(true)
		movement:start(target.entity)
		function movement:on_finished()
			print("unfreeze")
			target:unfreeze()
		end
	else
		target.entity:receive_attack_animation(self.entity)
	end
	
	if target.life <= 0 then
		target:kill()
	end
end

function entitydata:kill()
	if self.entity.ishero then
		hero = self.entity
		newentity = self:unpossess()
		newentity.entitydata:kill()
		
		hero:unfreeze()
		hero:set_tunic_sprite_id("hero/droppedsword")
		hero:set_animation("stopped")
		hero:freeze()
		hero.isdropped = true
		
	else
		self:freeze()
		self.entity:set_life(0)
	end
	
	self.entity.entitydata = nil
end

function entitydata:throwsword(entitydata2)
	if self.entity.ishero then
		if self.usingability ~= nil then
			return
		end
		
		if hero.isthrown then
			return
		end
		hero.isthrown = true
		
		if entitydata2 == nil then
			print("no entity!")
			return
		end
		
		hero = self.entity
		hero.isthrown = true
		hero:freeze()
		
		print("throwing to", entitydata2.team)
		
		newentity = self:unpossess()
		
		hero:set_tunic_sprite_id("hero/thrownsword")
		hero:set_animation("stopped")
		
		local movement = sol.movement.create("target")
		movement:set_speed(500)
		movement:set_target(entitydata2.entity)
		movement:start(hero)
		function movement:on_finished()
			entitydata2:bepossessedbyhero()
		end
	end
end

return entitydata
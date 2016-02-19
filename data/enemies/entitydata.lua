entitydata = {}

function entitydata:log(...)
	print(self.class, ...)
end

function entitydata:new(entity, class, main_sprite, life, team, swordability, transformability)
	-- use createfromclass
	self.entity = entity
	self.class = class
	self.main_sprite = main_sprite
	self.life = life
	self.team = team
	self.swordability = swordability
	self.transformability = transformability
end

function entitydata:createfromclass(entity, class)
	if class == "purple" then
		self:new(entity, class, "hero/tunic3", 10, "purple", sol.main.load_file("abilities/sword")(self), sol.main.load_file("abilities/swordtransform")(self, "fire"))
	elseif class == "green" then
		self:new(entity, class, "hero/tunic1", 10, "green", sol.main.load_file("abilities/sword")(self), sol.main.load_file("abilities/swordtransform")(self, "ap"))
	elseif class == "yellow" then
		self:new(entity, class, "hero/tunic2", 10, "yellow", sol.main.load_file("abilities/sword")(self), sol.main.load_file("abilities/swordtransform")(self, "electric"))
	else
		self:log("ERROR! no such class")
	end
end

function entitydata:applytoentity()
	-- changes entities appearance to reflect self
	self.entity.entitydata = self
	
	if self.entity.ishero then
		self.entity:set_tunic_sprite_id(self.main_sprite)
	else
		self.entity:load_entitydata()
	end
end

function entitydata:bepossessedbyhero()
	-- control this entitydata
	
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
	
	self:log("sword has possessed")
end

function entitydata:unpossess()
	-- create NPC entity for entitydata
	
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
	
	self:log("sword has left")
	
	return self.entity
end



function entitydata:isvisible()
	-- can be seen
	
	if self.entity.ishero and not self.entity.is_possessing then
		return false
	end
	return true
end

function entitydata:getability(ability)
	-- string to object
	if ability == "sword" then
		return self.swordability
	elseif ability == "swordtransform" then
		return self.transformability
	end
end

function entitydata:startability(ability)
	-- call this to use an ability
	if self.usingability == nil then
		ability = self:getability(ability)
		ability:start()
	end
end

function entitydata:withinrange(ability, entitydata)
	-- if an entity can be attacked using the ability
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

function entitydata:freeze(type, priority, cancelfunction)
	-- prevent movement due to input or AI
	if self.freezetype == nil or self.freezepriority == nil or priority >= self.freezepriority then
		if self.freezetype ~= nil then self:log("overriding freeze", self.freezetype,"->",type, self.freezepriority,"->",priority) end
		if self.freezecancel ~= nil then
			self:log("cancel freeze", self.freezetype, self.freezecancel()) 
			self.freezecancel()
		end
		self.freezetype = type
		self.freezepriority = priority
		
		if self.entity.ishero then
			self.entity:freeze()
		else
			self.entity:tick("frozen")
		end
		
		self:log("freezing", type)
		
		return true
	else
		self:log("couldn't freeze", type, self.freezetype)
	end
	
	return false
end

function entitydata:unfreeze(type, dotick)
	if dotick == nil then dotick = true end
	if type == "all" or type == self.freezetype then
		if self.entity.ishero then
			self.entity:unfreeze()
		else
			self.entity.state = nil
			if dotick then
				self.entity:tick()
			end
		end
		
		self.freezetype = nil
		self.freezepriority = 0
		self.freezecancel = nil
		
		self:log("unfreezing", type)
		
		return true
	else
		self:log("couldn't unfreeze", type, self.freezetype)
	end
	
	return false
end

function entitydata:dodamage(target, damage, aspects)
	-- call this to damage the target
	if target.team == self.team then
		self:log("friendly fire off")
		return
	end
	
	-- aspects
	knockback = 26
	if aspects == nil then
		aspects = {}
		self:log("reset aspects")
	end
	if aspects.ap ~= nil then
		self:log("armor piercing")
	end
	if aspects.stun ~= nil then
		self:log("stun")
		knockback = 0
		
		if target.freezetype ~= "stun" then
			pa = target:physicaleffectanimation("stun", aspects.stun)
			
			target:freeze("stun", 3, function() pa:cancel() end)
			sol.timer.start(self, aspects.stun, function() target:unfreeze("stun") end)
		end
	end
	if aspects.fire ~= nil then
		-- TODO: put into generic time-based effect thingy
		time = aspects.fire.time
		firedamage = aspects.fire.damage
		timestep = aspects.fire.timestep
		counter = time
		
		function dofiredamage()
			self:dodamage(target, firedamage, {firedamage=true})
			counter = counter - timestep
			if counter > 0 then
				sol.timer.start(self, timestep, function() dofiredamage() end)
			end
		end
		dofiredamage()
		
		pa = target:physicaleffectanimation("fire", time)
	end
	if aspects.firedamage ~= nil then
		knockback = 0
	end
	
	-- do damage
	target.life = target.life - damage
	target:log("damaged", damage, "life", target.life)
	
	--aggro
	if not target.entity.ishero then
		target.entity.entitytoattack = self
	end
	
	--cancel enemy's ability
	if target.usingability ~= nil then
		target.usingability:cancel()
	end
	
	--knockback
	if knockback ~= 0 then
		if target.entity.ishero then
			target:freeze("knockback", 2)
			local x, y = target.entity:get_position()
			local angle = target.entity:get_angle(self.entity) + math.pi
			local movement = sol.movement.create("straight")
			movement:set_speed(128)
			movement:set_angle(angle)
			movement:set_max_distance(26)
			movement:set_smooth(true)
			movement:start(target.entity)
			function movement:on_finished()
				target:unfreeze("knockback")
			end
		else
			target.entity:receive_attack_animation(self.entity)
		end
	end
	
	if target.life <= 0 then
		target:kill()
	end
end

function entitydata:physicaleffectanimation(name, time)
	-- TODO: put into generic time-based effect thingy
	entity = self.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	
	paentity = map:create_custom_entity({model="physicaleffect", x=x, y=y, layer=layer, direction=0, width=w, height=h})
	
	paentity:start(self, name, time)
	
	return paentity
end

function entitydata:kill()
	-- adventurer/monster is killed
	self:unfreeze("all")
	if self.entity.ishero then
		-- drop sword
		hero = self.entity
		newentity = self:unpossess()
		newentity.entitydata:kill()
		
		hero:unfreeze()
		hero:set_tunic_sprite_id("hero/droppedsword")
		hero:set_animation("stopped")
		hero:freeze()
		hero.isdropped = true
		
	else
		self:freeze("dead", 5)
		self.entity:set_life(0)
	end
	
	self.entity.entitydata = nil
end

function entitydata:throwsword(entitydata2)
	self:log("going to throw to", entitydata2.class)
	if self.entity.ishero then
		if self.usingability ~= nil then
			return
		end
		
		if hero.isthrown then
			return
		end
		
		if entitydata2 == nil then
			self:log("no entity!")
			return
		end
		
		if not entitydata2.entity:exists() then
			self:log("doesn't exist!")
			return
		end
		
		if not entitydata2.entity.hasbeeninitialized then
			self:log("Not init!")
			return
		end
		
		hero.isthrown = true
		
		hero = self.entity
		hero.isthrown = true
		hero:freeze()
		
		self:log("throwing to", entitydata2.team)
		
		newentity = self:unpossess()
		
		hero:set_tunic_sprite_id("hero/thrownsword")
		hero:set_animation("stopped")
		
		hero:stop_movement()
		self:log(entitydata2.entity:get_position())
		
		local movement = sol.movement.create("target")
		movement:set_speed(500)
		movement:set_target(entitydata2.entity)
		movement:start(hero)
		function movement:on_finished()
			entitydata2:bepossessedbyhero()
		end
	end
end

function entitydata:throwrandom()
	-- throw sword to random entity
	require "math"
	
	map = game:get_map()
	hero = game:get_hero()
	
	entitieslist = {}
	for entity in map:get_entities("") do
		if entity.entitydata ~= nil then
			if not entity.entitydata.ishero then
				entitieslist[#entitieslist+1] = entity
			end
		end
	end
	
	entity = entitieslist[math.random(#entitieslist)]
	
	if entity ~= nil then
		if hero.entitydata ~= nil then
			hero.entitydata:throwsword(entity.entitydata)
		end
--		hero.entitydata:unpossess()
--		entity.entitydata:bepossessedbyhero()
	end
end


return entitydata
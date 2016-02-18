local enemy = ...

-- Generic script for an enemy with a sword
-- that goes towards the hero if he sees him
-- and walks randomly otherwise.

-- Example of use from an enemy script:

-- sol.main.load_file("enemies/generic_soldier")(enemy)
-- enemy:set_properties({
--	 main_sprite = "enemies/green_knight_soldier",
--	 sword_sprite = "enemies/green_knight_soldier_sword",
--	 life = 4,
--	 damage = 2,
--	 play_hero_seen_sound = false,
--	 normal_speed = 32,
--	 faster_speed = 64,
--	 hurt_style = "normal"
-- })

-- The parameter of set_properties() is a table.
-- Its values are all optional except main_sprite
-- and sword_sprite.

-- local properties = {}
-- local going_hero = false
-- local being_pushed = false
-- local main_sprite = nil

-- constants:
RANDOM = "random"
GOHERO = "go_hero"
ATTACK = "attack"
PUSHED = "being_pushed"
play_hero_seen_sound = false
normal_speed = 32
faster_speed = 32--64

function enemy:set_class(class_string)
	self.class = class_string
end

function enemy:on_created()
	if self.class ~= nil then
		self.entitydata = sol.main.load_file("enemies/entitydata")()
		self.entitydata:createfromclass(self, self.class)
		
		self:load_entitydata()
	end
	
	self:set_life(9999)
	self:set_damage(0)
	self:set_hurt_style("normal")
	self.direction = 0
	
	self.ishero = false
	
	self.is_swinging_sword = false
	self.state = nil
	self.hitbyentity = nil
	
	self.sword_sprite = self:create_sprite("hero/sword3")
	self:set_size(16, 16)
	self:set_origin(8, 13)

	self:set_invincible_sprite(self.sword_sprite)
	self:set_attack_consequence_sprite(self.sword_sprite, "sword", "custom")
	
	self:reset_everything()
end

function enemy:load_entitydata()
	self.main_sprite = self:create_sprite(self.entitydata.main_sprite)
end

function enemy:on_restarted()
	if self.state ~= PUSHED then
		self:tick()
	end
end

function enemy:close_to(entity)
	local _, _, layer = self:get_position()
	local _, _, hero_layer = entity:get_position()
	return layer == hero_layer and self:get_distance(entity) < 40
end

function enemy:targetenemy()
	entitieslist = {}
	
	local hero = self:get_map():get_entity("hero")
	if self:cantargetentity(hero) then
		entitieslist[#entitieslist+1] = hero
	end
	
	map = self:get_map()
	for entity in map:get_entities("") do
		if self:cantargetentity(entity) and entity ~= hero then
			entitieslist[#entitieslist+1] = entity
		end
	end
	
	function entitieslist.contains(table, element)
	  for _, value in pairs(table) do
	    if value == element then
	      return true
	    end
	  end
	  return false
	end
	
	if entitieslist:contains(self.entitytoattack) then
		return self.entitytoattack
	end
	
	return entitieslist[math.random(#entitieslist)]
end

function enemy:cantargetentity(entity)
	if entity.entitydata == nil then return false end
	if entity.entitydata.team == self.entitydata.team then return false end
	if not entity.entitydata:isvisible() then return false end
	if self:get_distance(entity) > 100 then return false end
	
	return true
end

function enemy:determinenewstate(entitytoattack, currentstate)
	if currentstate == PUSHED then
		return PUSHED
	end
	
	if entitytoattack == nil then
		return RANDOM
	end
			
	if self:close_to(entitytoattack) then
		return ATTACK
	end
	
	return GOHERO
end

function enemy:tick(newstate)
	if self.entitydata ~= nil then
	
	prevstate = self.state
	preventitytoattack = self.entitytoattack
	
	self.entitytoattack = self:targetenemy()

	if (newstate == nil) then
		self.state = self:determinenewstate(self.entitytoattack, currentstate)
	else
		self.state = newstate
	end
	
	changedstates = (prevstate ~= self.state or preventitytoattack ~= self.entitytoattack)
	
	if changedstates then
		-- changed states
		self:reset_everything()
		print("changed states from", prevstate, "to", self.state)
		if prevstate == ATTACK then
			self:dont_attack(self.entitytoattack)
		end
	end
	
	if self.state == ATTACK then
		self:go_attack(changedstates, self.entitytoattack)
	elseif self.state == GOHERO then
		self:go_hero(changedstates)
	elseif self.state == RANDOM then
		self:go_random(changedstates)
	elseif self.state == PUSHED then
		self:go_pushed(changedstates)
	end
	
	end
	sol.timer.start(self, 500, function() self:tick() end)
end

function enemy:on_movement_changed(movement)
	if self.state ~= PUSHED then
		self:setdirection(movement:get_direction4())
	end
end

function enemy:setdirection(d)
	self.direction = d
	self.main_sprite:set_direction(d)
	self.sword_sprite:set_direction(d)
end

function enemy:on_movement_finished(movement)
	if self.state == PUSHED then
		self.state = nil
		self:tick()
	end
end

function enemy:on_obstacle_reached(movement)
	if self.state == PUSHED then
		self.state = nil
		self:tick()
	end
end

function enemy:on_custom_attack_received(attack, sprite)
	if attack == "sword" and sprite == self.sword_sprite then
		sol.audio.play_sound("sword_tapping")
		self:receive_attack_animation(self:get_map():get_entity("hero"))
	end
end

function enemy:receive_attack_animation(entity)
	print("going to push")
	self.hitbyentity = entity
	self:tick(PUSHED)
end

function enemy:go_pushed(changedstates)
	if changedstates then
		local x, y = self:get_position()
		local angle = self:get_angle(self.hitbyentity) + math.pi
		local movement = sol.movement.create("straight")
		movement:set_speed(128)
		movement:set_angle(angle)
		movement:set_max_distance(26)
		movement:set_smooth(true)
		movement:start(self)
	end
end

function enemy:go_random(changedstates)
	if changedstates then
		local movement = sol.movement.create("random_path")
		movement:set_speed(normal_speed)
		movement:start(self)
	end
end

function enemy:go_hero(changedstates)
	if changedstates then
		local movement = sol.movement.create("target")
		movement:set_speed(faster_speed)
		movement:start(self)
	end
end

function enemy:go_attack(changedstates, hero)
	if not self.is_swinging_sword then
		self:swingsword(hero)
	end
	direction = self:get_direction4_to(hero)
	self.main_sprite:set_direction(direction)
	self.sword_sprite:set_direction(direction)
end

function enemy:swingsword(hero)
	self.is_swinging_sword = true
	print("swinging sword")
	movement = self:get_movement()
	if movement ~= nil then
		movement:stop(self)
	end
	self.sword_sprite:set_animation("sword")
	self.sword_sprite:set_paused(false)
	self.main_sprite:set_animation("sword")
	self.sword_sprite:synchronize(self.main_sprite)
	sol.timer.start(self, 100, function() self:actually_attack(hero) end)
	
	function self.main_sprite.on_animation_finished (sprite, animation)
		self.is_swinging_sword = false
		self:tick()
	end
end

function enemy:dont_attack(hero)
	self.is_swinging_sword = false
end

function enemy:reset_everything()
	self.sword_sprite:set_animation("walking")
	self.main_sprite:set_animation("walking")
	self.sword_sprite:synchronize(nil)
	self.main_sprite:set_paused(false)
end


function enemy:actually_attack(hero)
	-- TODO: pixel collision
	if self:close_to(hero) then
		print("hit")
	end
end

function enemy:on_attacking_hero(hero, enemy_sprite)
end
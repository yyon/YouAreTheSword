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
local class
-- local going_hero = false
-- local being_pushed = false
-- local main_sprite = nil
RANDOM = "random"
GOHERO = "go_hero"
ATTACK = "attack"
PUSHED = "being_pushed"
local state = nil
local sword_sprite = nil

play_hero_seen_sound = false
normal_speed = 32
faster_speed = 64
is_swinging_sword = false


function enemy:set_class(class_string)
	class = class_string
end

function enemy:on_created()
	self.entitydata = sol.main.load_file("enemies/entitydata")()
	self.entitydata:createfromclass(self, class)
	
	self:set_life(9999)
	self:set_damage(0)
	self:set_hurt_style("normal")
	
	sword_sprite = self:create_sprite("hero/sword3")
	main_sprite = self:create_sprite(self.entitydata.main_sprite)
	self:set_size(16, 16)
	self:set_origin(8, 13)

	self:set_invincible_sprite(sword_sprite)
	self:set_attack_consequence_sprite(sword_sprite, "sword", "custom")
end

function enemy:on_restarted()
	if state ~= PUSHED then
		self:tick()
	end
end

function enemy:close_to(entity)
	local _, _, layer = self:get_position()
	local _, _, hero_layer = entity:get_position()
	return layer == hero_layer and self:get_distance(entity) < 40
end

function enemy:tick(newstate)
	prevstate = state
	
	local hero = self:get_map():get_entity("hero")

	if (newstate == nil) then
		local _, _, layer = self:get_position()
		local _, _, hero_layer = hero:get_position()
		local near_hero = layer == hero_layer
			and self:get_distance(hero) < 100
	
		if self:close_to(hero) then
			state = ATTACK
		else
			state = nil
		end
	
		if near_hero and state ~= ATTACK then
			if play_hero_seen_sound then
				sol.audio.play_sound("hero_seen")
			end
			state = GOHERO
		elseif not near_hero then
			state = RANDOM
		end
	else
		print("forcing state", newstate)
		state = newstate
	end
	
	changedstates = (prevstate ~= state)
	
	if changedstates then
		-- changed states
		print("changed state to", state, "from", prevstate)
		if prevstate == ATTACK then
			self:dont_attack(hero)
		end
	end
	
	if state == ATTACK then
		self:go_attack(changedstates, hero)
	elseif state == GOHERO then
		self:go_hero(changedstates)
	elseif state == RANDOM then
		self:go_random(changedstates)
	elseif state == PUSHED then
		self:go_pushed(changedstates)
	end

--	sol.timer.stop_all(self)
	sol.timer.start(self, 500, function() self:tick() end)
end

function enemy:on_movement_changed(movement)
	if state ~= PUSHED then
		local direction4 = movement:get_direction4()
		main_sprite:set_direction(direction4)
		sword_sprite:set_direction(direction4)
	end
end

function enemy:on_movement_finished(movement)
	if state == PUSHED then
		state = nil
		self:tick()
	end
end

function enemy:on_obstacle_reached(movement)
	if state == PUSHED then
		state = nil
		self:tick()
	end
end

function enemy:on_custom_attack_received(attack, sprite)
	if attack == "sword" and sprite == sword_sprite then
		sol.audio.play_sound("sword_tapping")
		self:receive_attack_animation(self:get_map():get_entity("hero"))
	end
end

function enemy:receive_attack_animation(entity)
	print("going to push")
	self:tick(PUSHED)
end

function enemy:go_pushed(changedstates)
	if changedstates then
		local x, y = self:get_position()
		local angle = self:get_angle(entity) + math.pi
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
	
		sword_sprite:set_animation("walking")
		main_sprite:set_animation("walking")
		sword_sprite:synchronize(nil)
		main_sprite:set_paused(false)
	end
end

function enemy:go_hero(changedstates)
	if changedstates then
		local movement = sol.movement.create("target")
		movement:set_speed(faster_speed)
		movement:start(self)
	
		sword_sprite:set_animation("walking")
		main_sprite:set_animation("walking")
		sword_sprite:synchronize(nil)
		main_sprite:set_paused(false)
	end
end

function enemy:go_attack(changedstates, hero)
	if not is_swinging_sword then
		self:swingsword(hero)
	end
	direction = self:get_direction4_to(hero)
	main_sprite:set_direction(direction)
	sword_sprite:set_direction(direction)
end

function enemy:swingsword(hero)
	is_swinging_sword = true
	print("swinging sword")
	movement = self:get_movement()
	if movement ~= nil then
		movement:stop(self)
	end
	sword_sprite:set_animation("sword")
	sword_sprite:set_paused(false)
	main_sprite:set_animation("sword")
	sword_sprite:synchronize(main_sprite)
	sol.timer.start(self, 100, function() self:actually_attack(hero) end)
	
	function main_sprite.on_animation_finished (sprite, animation)
		is_swinging_sword = false
		self:tick()
	end
end

function enemy:dont_attack(hero)
	is_swinging_sword = false
end

function reset_everything()
	sword_sprite:set_animation("walking")
	main_sprite:set_animation("walking")
	sword_sprite:synchronize(nil)
	main_sprite:set_paused(false)
end


function enemy:actually_attack(hero)
	-- TODO: pixel collision
	if self:close_to(hero) then
		print("hit")
	end
end

function enemy:on_attacking_hero(hero, enemy_sprite)
end
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

local class = require "middleclass"
require "math"

-- constants:
--[[
RANDOM = "random"
GOHERO = "go_towards"
--ATTACK = "attack"
PUSHED = "being_pushed"
FROZEN = "frozen"
GOPICKUP = "pickup"
--]]
play_hero_seen_sound = false
normal_speed = 64

enemy.hasbeeninitialized = false

State = class("State")

function State:initialize(npc)
	self.npc = npc
end

function State:ontick(changedstates)
	if changedstates then
		self:start()
	end
	self:tick()
end

function State:cleanup()
	self.npc:reset_everything()
end

function State:vartorecord()
end

function State:prevvar()
	self.prev_var = self:vartorecord()
end

function State:requiresupdate()
	if self.prev_var ~= self:vartorecord() then
		return true
	end
	return false
end

NilState = State:subclass("NilState")
function NilState:start()
end
function NilState:tick()
end

RandomState = State:subclass("RandomState")

function RandomState:start()
	if self.npc.entitydata.stats.movementspeed ~= 0 then
		local movement = sol.movement.create("random_path")
		movement:set_speed(normal_speed)
		movement:start(self.npc)
	end
end

function RandomState:tick()
end

PushedState = State:subclass("PushedState")

function PushedState:start()
	local x, y = self.npc:get_position()
	local angle = self.npc:get_angle(self.npc.hitbyentity) + math.pi
	local movement = sol.movement.create("straight")
	movement:set_speed(128)
	movement:set_angle(angle)
	movement:set_max_distance(26)
	movement:set_smooth(true)
	movement:start(self.npc)
end

function PushedState:tick()
end

FrozenState = State:subclass("FrozenState")

function FrozenState:start()
end

function FrozenState:tick()
end

DoNothingState = State:subclass("DoNothingState")

function DoNothingState:start()
end

function DoNothingState:tick()
end

GoTowardsState = State:subclass("GoTowardsState")

function GoTowardsState:start()
	if self.npc.entitytoattack ~= nil then
		x, y = self.npc.entitytoattack.entity:get_position()
		
		if self.npc.entitydata.alwaysrandom then
			local movement = sol.movement.create("random_path")
			movement:set_speed(normal_speed)
			movement:start(self.npc)
		else
			local movement = sol.movement.create("target") -- "path_finding")
			movement:set_speed(self.npc.entitydata.stats.movementspeed)
			movement:set_target(self.npc.entitytoattack.entity)
			movement:set_smooth(true)
			movement:start(self.npc)
		end
		self.movement = movement
	end
end

function GoTowardsState:tick()
	if self.npc.entitydata.entity:get_game().dontattack then
		return
	end
	target = self.npc.entitytoattack

	attackability = math.random(10) == 1 and "special" or "normal"
	cantusespecial = false
	if not self.npc.entitydata:canuseability("special") or self.npc.entitydata:getability("special").nonpc then
		cantusespecial = true
		attackability = "normal"
	end
	if not self.npc.entitydata:canuseability("normal") or self.npc.entitydata:getability("normal").nonpc then
		if cantusespecial then
			attackability = nil
		else
			attackability = "special"
		end
	end
	
	x, y = target.entity:get_position()
	if target ~= nil then
		if self.npc.entitydata.entity:get_distance(target.entity) < 20 then
			if self.movement ~= nil then
				self.movement:stop()
				self.movement = nil
			end
		else
			if self.movement == nil then
				self:start()
			end
		end

		targetability = target.usingability
		if targetability ~= nil and targetability.abilitytype ~= "block" and self.npc:get_distance(target.entity) < targetability.range then
			-- block if being attacked
			ability = self.npc.entitydata:startability("block")
		elseif attackability ~= nil then
			-- attack if close enough
			if self.npc.entitydata:withinrange(attackability, target) then
				self.npc.entitydata:startability(attackability, x, y)
			end
		end
	end
end

function GoTowardsState:vartorecord()
	return self.npc.entitytoattack
end

PickupState = State:subclass("PickupState")

function PickupState:start()
	local movement = sol.movement.create("target")
	movement:set_speed(self.npc.entitydata.stats.movementspeed)
	movement:set_target(self.npc.target)
	movement:start(self.npc)
end

function PickupState:tick()
	if self.npc:get_distance(self.npc.target) < 20 then
		self.npc.entitydata:bepossessedbyhero()
	end
end

function PickupState:vartorecord()
	return self.npc.target
end



function enemy:on_created()
	-- initialize

	self:set_life(9999) -- life is now managed by entitydata not by solarus
	self:set_damage(0)
	self:set_hurt_style("normal")
	self.direction = 0
	self:set_invincible()
	self:set_optimization_distance(0)

	self.ishero = false

	self.is_swinging_sword = false
	self.state = nil
	self.hitbyentity = nil

	self:set_size(16, 16)
	self:set_origin(8, 13)

	self.nilstate = NilState:new(self)
	self.randomstate = RandomState:new(self)
	self.gotowardsstate = GoTowardsState:new(self)
	self.pushedstate = PushedState:new(self)
	self.frozenstate = FrozenState:new(self)
	self.pickupstate = PickupState:new(self)
	self.donothingstate = DoNothingState:new(self)
end

function enemy:load_entitydata()
	if self.main_sprite ~= nil then
		self:remove_sprite(self.main_sprite)
	end
	self.main_sprite = self:create_sprite(self.entitydata.main_sprite)
end

function enemy:on_restarted()
--	self:tick()
	if self.ticker == nil then
		self.ticker = Effects.Ticker:new(self:get_game(), 500, function() self:tick() end)
	end
end

function enemy:on_removed()
	if self.ticker ~= nil then
		self.ticker:remove()
		self.ticker = nil
	end
end

function enemy:close_to(entity)
	local _, _, layer = self:get_position()
	local _, _, hero_layer = entity:get_position()
	dist = self:get_distance(entity)
	if layer ~= hero_layer then
		return false
	end
	if dist > 40 then
		return false
	end
	return true
end

function enemy:targetenemy()
	entitieslist = {}

	local hero = self:get_map():get_entity("hero")
--	if self:cantargetentity(hero) then
--		entitieslist[#entitieslist+1] = hero.entitydata
--	end

	if hero.isdropped and self.entitydata.team == "adventurer" then
		return hero
	end
	
	taunt = self:get_map().taunt
	if taunt ~= nil then
		if self:cantarget(taunt) then
			return taunt
		end
	end
	
	if self.entitytoattack ~= nil then
		if self:cantarget(self.entitytoattack) then
			return self.entitytoattack
		end
	end

--	for entitydata in self.entitydata:getotherentities() do
--		if self:cantarget(entitydata) then
--			entitieslist[#entitieslist+1] = entitydata
--		end
--	end

--[[
	function entitieslist.contains(table, element)
	  for _, value in pairs(table) do
	    if value == element then
	      return true
	    end
	  end
	  return false
	end
--]]

--	if entitieslist:contains(self.entitytoattack) then
--		return self.entitytoattack
--	end
	
	
	
--	return entitieslist[math.random(#entitieslist)]
	x, y = self:get_position()
	return self.entitydata:getclosestentity(x, y, nil, function(entitydata) return self:cantarget(entitydata) end)
end

function enemy:cantarget(entitydata)
	if not self.entitydata:cantarget(entitydata) then return false end
--	if self:get_distance(entitydata.entity) > 200 and self.entitytoattack == nil then
--		return false
--	end
--	if self:get_distance(entitydata.entity) > 800 then
--		return false
--	end

	return true
end


function enemy:determinenewstate(entitytoattack, currentstate)
	hero = self:get_game():get_hero()
	
	if self:get_distance(hero) > 700 and not self.hasbeenhit then
		return self.donothingstate
	end
	
	if currentstate == self.pushedstate then
		return currentstate
	end

	if currentstate == self.frozenstate then
		return currentstate
	end
	
	if self.entitydata.dontmove then
		return self.donothingstate
	end

	if entitytoattack == nil then
		return self.randomstate
	end

	if entitytoattack.isdropped then
		return self.pickupstate
	end

	return self.gotowardsstate
end

function enemy:resetstate()
	if self.entitydata ~= nil then
		self.prevstate = nil
		self.state = nil
		self:tick(self.nilstate)
	end
end

function enemy:tick(newstate)
	if not self:exists() then return end
	
	if self.entitydata ~= nil and not game:is_paused() and not game:is_suspended() then
	
	self.hasbeeninitialized = true

	prevstate = self.state
	if prevstate == nil then prevstate = self.nilstate end
--	preventitytoattack = self.entitytoattack
	prevstate:prevvar()

	self.entitytoattack = self:targetenemy()
	if (self.entitytoattack ~= nil) then
		if self.entitytoattack.isdropped then
			target = self.entitytoattack
			self.entitytoattack = nil
		else
			target = self.entitytoattack.entity
			self.lasttarget = self.entitytoattack
		end
	else
		target = nil
	end
	self.target = target

	if (newstate == nil) then
		self.state = self:determinenewstate(target, self.state)
	else
		self.state = newstate
	end
	if self.state == nil then self.state = self.NilState end

	changedstates = (prevstate ~= self.state or self.state:requiresupdate())

	if changedstates then
		prevstate:cleanup()
--		self.entitydata:log("changed states from", prevstate, "to", self.state, self.entitytoattack and "Target: "..self.entitytoattack.team or "")
	end
	self.state:ontick(changedstates)
--[[
	if changedstates then
		-- changed states
		self:reset_everything()
		self.entitydata:log("changed states from", prevstate, "to", self.state, self.entitytoattack and "Target: "..self.entitytoattack.team or "")

--		if prevstate == ATTACK then
--			self:dont_attack(target)
--		end
	end

--	if self.state == ATTACK then
--		self:go_attack(changedstates, target)
	if self.state == GOHERO then
		self:go_hero(changedstates)
	elseif self.state == RANDOM then
		self:go_random(changedstates)
	elseif self.state == PUSHED then
		self:go_pushed(changedstates)
	elseif self.state == GOPICKUP then
		self:go_pickup(changedstates, target)
	end
--]]

	end

--	sol.timer.start(self, 500, function() self:tick() end)
end

function enemy:on_movement_changed(movement)
	if self.state ~= self.pushedstate then
		self:setdirection(movement:get_direction4())
	end
end

function enemy:setdirection(d)
	if not self.cantrotate then
		self.direction = d
		self.main_sprite:set_direction(d)
	end
--	self.sword_sprite:set_direction(d)
end

function enemy:on_movement_finished(movement)
	if self.state == self.pushedstate then
		self.state = nil
		self:tick()
	end
end

function enemy:on_obstacle_reached(movement)
	if self.state == self.pushedstate then
		self.state = nil
		self:tick()
	end
end

function enemy:on_custom_attack_received(attack, sprite)
--	if attack == "sword" and sprite == self.sword_sprite then
--		sol.audio.play_sound("sword_tapping")
--		self:receive_attack_animation(self:get_map():get_entity("hero"))
--	end
end

function enemy:receive_attack_animation(entity)
	self.hitbyentity = entity
	self:tick(self.pushedstate)
end

--[[
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
		self.entitydata:log("random", changedstates)
		local movement = sol.movement.create("random_path")
		movement:set_speed(normal_speed)
		movement:start(self)
	end
end

function enemy:go_hero(changedstates)
	if changedstates then
		if self.entitytoattack ~= nil then
			local movement = sol.movement.create("target")
			movement:set_speed(faster_speed)
			movement:set_target(self.entitytoattack.entity)
			movement:start(self)
		end
	end

	if self.entitytoattack ~= nil then
		if self.entitydata:withinrange("sword", self.entitytoattack) then
			self.entitydata:startability("sword")
		end
	end
end

function enemy:go_pickup(changedstates, target)
	if changedstates then
		local movement = sol.movement.create("target")
		movement:set_speed(faster_speed)
		movement:set_target(target)
		movement:start(self)
	end

	if self:get_distance(target) < 20 then
		self.entitydata:log("POSSESS")
		self.entitydata:bepossessedbyhero()
	end
end
--]]

--[[
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
	self.entitydata:log("swinging sword")
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
--]]
function enemy:reset_everything()
--	self.sword_sprite:set_animation("walking")
	self.main_sprite:set_animation("walking")
--	self.sword_sprite:synchronize(nil)
	self.main_sprite:set_paused(false)

	if self:get_movement() ~= nil then
		self:get_movement():stop()
	end
end


function enemy:actually_attack(hero)
	-- TODO: pixel collision
	if self:close_to(hero) then
	end
end

function enemy:on_attacking_hero(hero, enemy_sprite)
end

BLOCKJUMP = 100

function enemy:getblockposition(target)
	angle = self:get_angle(target.entity)
	if math.random(1,2) == 1 then
		angle = angle + math.pi/2
	else
		angle = angle - math.pi/2
	end
	
	x, y = self:get_position()
	x, y = x + math.cos(angle)*BLOCKJUMP, y + math.sin(angle)*BLOCKJUMP
	
	return x,y
end

function enemy:on_position_changed(x, y, layer)
	if self.entitydata ~= nil then
		self.entitydata:updatechangepos(x,y,layer)
	end
end

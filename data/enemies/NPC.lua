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
local math = require "math"
local Effects = require "enemies/effect"

-- constants:
--[[
RANDOM = "random"
GOHERO = "go_towards"
--ATTACK = "attack"
PUSHED = "being_pushed"
FROZEN = "frozen"
GOPICKUP = "pickup"
--]]
--local play_hero_seen_sound = false
local normal_speed = 64

enemy.hasbeeninitialized = false

local State = class("State")

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

local NilState = State:subclass("NilState")

function NilState:start()
end
function NilState:tick()
end

local RandomState = State:subclass("RandomState")

function RandomState:start()
	if self.npc.entitydata.stats.movementspeed ~= 0 then
		local movement = sol.movement.create("random_path")
		movement:set_speed(normal_speed)
		movement:start(self.npc)
	end
end

function RandomState:tick()
end

local PushedState = State:subclass("PushedState")

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

local FrozenState = State:subclass("FrozenState")

function FrozenState:start()
end

function FrozenState:tick()
end

local DoNothingState = State:subclass("DoNothingState")

function DoNothingState:start()
	if self.npc.entitydata ~= nil then
		self.npc.entitydata:setanimation("stopped")
	end
end

function DoNothingState:tick()
end

local GoTowardsState = State:subclass("GoTowardsState")

function GoTowardsState:start()
	if self.npc.entitytoattack ~= nil then
		local movement
		if self.npc.entitydata.alwaysrandom then
			movement = sol.movement.create("random_path")
			movement:set_speed(normal_speed)
			movement:start(self.npc)
		else
			self.npc:pathfind(self.npc.entitytoattack.entity)
		end
	end
end

function GoTowardsState:tick()
	if self.npc.entitydata.entity:get_game().dontattack then
		return
	end

	local target = self.npc.entitytoattack

	local attackability = math.random(10) == 1 and "special" or "normal"
	local cantusespecial = false
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

	if target ~= nil and target.entity ~= nil then
		local x, y = target.entity:get_position()
		local d = self.npc:get_direction4_to(target.entity)
		self.npc:setdirection(d)

--[[		if self.npc.entitydata.entity:get_distance(target.entity) < 20 then
			if self.movement ~= nil then
				self.movement:stop()
				self.movement = nil
			end
		else
			if self.movement == nil then
				self:start()
			end
		end --]]

		local targetability = target.usingability
		if targetability ~= nil and targetability.abilitytype ~= "block" and self.npc:get_distance(target.entity) < targetability.range then
			-- block if being attacked
			local ability = self.npc.entitydata:startability("block")
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

function GoTowardsState:cleanup()
	State.cleanup(self)
	if self.pathfindingtimer ~= nil then
		self.pathfindingtimer:stop()
	end
end

local GoAwayState = GoTowardsState:subclass("GoAwayState")

function GoAwayState:start()
	if self.npc.entitytoattack ~= nil then
		local x, y = self.npc:getblockposition(self.npc.entitytoattack, true)

		local movement = sol.movement.create("target")
		movement:set_speed(self.npc.entitydata.stats.movementspeed)
		movement:set_target(x,y)
		movement:set_smooth(true)
		movement:start(self.npc)

		if self.npc.entitydata ~= nil then
			Effects.SimpleTimer(self.npc.entitydata, 200, function() self.npc:tick() end)
		end
	end
end

local StandAndAttackState = GoTowardsState:subclass("StandAndAttackState")

function StandAndAttackState:start()
end

local PickupState = State:subclass("PickupState")

function PickupState:start()
	if self.npc.target ~= nil then
		local movement
		if self.npc.entitydata.stats.movementspeed ~= 0 then
			local tox, toy = self.npc.target:get_position()
			if not self.npc.entitydata:canmoveto(tox, toy) then
				if not self.npc:get_map():get_floor() == 1 then
					movement = self.npc:pathfind(self.npc.target)
				end
			else
				movement = sol.movement.create("target") -- "path_finding")
				movement:set_speed(self.npc.entitydata.stats.movementspeed)
				movement:set_target(self.npc.target)
				movement:set_smooth(true)
				movement:start(self.npc)
			end
		end
		self.movement = movement
	end
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
	self.goawaystate = GoAwayState:new(self)
	self.standandattackstate = StandAndAttackState:new(self)
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
	local dist = self:get_distance(entity)
	if layer ~= hero_layer then
		return false
	end
	if dist > 40 then
		return false
	end
	return true
end

function enemy:targetenemy()
--	local entitieslist = {}

	local hero = self:get_map():get_entity("hero")
--	if self:cantargetentity(hero) then
--		entitieslist[#entitieslist+1] = hero.entitydata
--	end

	if hero.isdropped and self.entitydata.team == "adventurer" then
		return hero
	end

	local taunt = self:get_map().taunt
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
	local x, y = self:get_position()
	local function cantargetfunction (entitydata)
		return self:cantarget(entitydata)
	end
	local closestentity = self.entitydata:getclosestentity(x, y, nil, cantargetfunction)
	return closestentity
end

function enemy:cantarget(entitydata)
	if not self.entitydata:cantarget(entitydata) then return false end
	if not entitydata:isvisible() then return false end
	if not entitydata.entity.ishero and not entitydata.entity.wasonscreen then return false end
--	if self:get_distance(entitydata.entity) > 200 and self.entitytoattack == nil then
--		return false
--	end
--	if self:get_distance(entitydata.entity) > 800 then
--		return false
--	end

	return true
end


function enemy:determinenewstate(entitytoattack, currentstate)
	local hero = self:get_game():get_hero()

--	if self:get_distance(hero) > 700 and not self.hasbeenhit then
	local floor = self:get_map():get_floor()

	if not self.wasonscreen and (floor ~= 0 and not self.entitydata:isonscreen(200)) then
		return self.donothingstate
	end

	if not self:is_in_same_region(hero) then
		return self.donothingstate
	end

	self.wasonscreen = true

	if currentstate == self.pushedstate then
		return currentstate
	end

	if currentstate == self.frozenstate then
		return currentstate
	end

	if self.entitydata.dontmove then
		return self.donothingstate
	end

	if entitytoattack ~= nil and entitytoattack.isdropped then
		return self.pickupstate
	end

	if floor == 1 then
		return self.donothingstate
	end

	if entitytoattack == nil then
		return self.randomstate
	end

	if entitytoattack ~= nil then
		if not self.entitydata.alwaysrandom then
			local d = self:get_distance(entitytoattack)
			if d < 20 then
				return self.goawaystate
			elseif d < 40 then
				return self.standandattackstate
			end
		end
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
	if self.removed then return end

	if self.entitydata ~= nil and not game:is_paused() and not game:is_suspended() then

	self.hasbeeninitialized = true

	local prevstate = self.state
	if prevstate == nil then prevstate = self.nilstate end
--	preventitytoattack = self.entitytoattack
	prevstate:prevvar()

	self.entitytoattack = self:targetenemy()
	local target
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

	local changedstates = (prevstate ~= self.state or self.state:requiresupdate())

	if changedstates then
		prevstate:cleanup()
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
	local soulsup = 0.01
	self.entitydata.souls = self.entitydata.souls + soulsup
	if self.entitydata.souls > 1 then
		self.entitydata.souls = 1
	end

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

local BLOCKJUMP = 100

function enemy:getblockposition(target, backwards)
	local angle = self:get_angle(target.entity)
	if backwards then
		angle = angle + math.pi
	else
		local r = math.random(1,3)
		if r == 1 then
			angle = angle + math.pi/2
		elseif r == 2 then
			angle = angle + math.pi
		else
			angle = angle - math.pi/2
		end
	end


	local x, y = self:get_position()
	x, y = x + math.cos(angle)*BLOCKJUMP, y + math.sin(angle)*BLOCKJUMP

	return x,y
end

function enemy:on_position_changed(x, y, layer)
	if self.entitydata ~= nil then
		self.entitydata:updatechangepos(x,y,layer)
	end
end

function enemy:pathfind(target)
	if target == nil then return end
	if self.entitydata.stats.movementspeed == 0 then return end
	if self.entitydata.caught then return end

	local tox, toy = target:get_position()
	if self.entitydata:canmoveto(tox, toy) then
		self:gotowards(target)
		return
	end

	local map = self:get_map()

	local x, y = self:get_position()
	x, y = map:getclosestgrid(x, y)
	if not x then
		print("can't start")
		self:gotowards(target)
		return
	end
	x, y = map:fromgrid(x, y)

	local movement = sol.movement.create("target")
	movement:set_speed(self.entitydata.stats.movementspeed)
	movement:set_target(x, y)
	movement:set_smooth(true)
	movement:start(self)

	function movement.on_finished(movement)
		local fromx, fromy = self:get_position()
		fromx, fromy = map:getclosestgrid(fromx, fromy)
		if not fromx then return end
		local tox, toy = target:get_position()
		tox, toy = map:getclosestgrid(tox, toy)
		if not tox then return end

--		print(self.entitydata.theclass, "pathfinding")

		local path = map.pathfinder:getPath(fromy, fromx, toy, tox, false)
		if path then
			path:fill()

			local prevx, prevy = fromx, fromy

			local dirpath = {}

--			local gridcopy = map:copygrid()

			local DIRS = {[-1]={[-1]=3, [0]=4, [1]=5}, [0]={[-1]=2, [1]=6}, [1]={[-1]=1, [0]=0, [1]=7}}

			local function move(dx, dy)
				local newx, newy = prevx + dx, prevy+dy
				local dir = DIRS[dx][dy]

--				gridcopy[newx][newy] = "O"

				prevx, prevy = newx, newy

				dirpath[#dirpath+1] = dir
			end

			for node, count in path:nodes() do
				local y, x = node.x, node.y
				local dx, dy = x-prevx, y-prevy
				if dx == 0 or dy == 0 then
					move(dx, dy)
				else
					if map.gridtable[prevx+dx][prevy] == 0 and map.gridtable[prevx][prevy+dy] == 0 then
						move(dx, dy)
					elseif map.gridtable[prevx+dx][prevy] == 0 then
						move(dx, 0)
						move(0, dy)
					elseif map.gridtable[prevx][prevy+dy] == 0 then
						move(0, dy)
						move(dx, 0)
					else
						move(dx, dy)
					end
				end
			end

--			map:printgrid(gridcopy)

			local movement = sol.movement.create("path")
			movement:set_speed(self.entitydata.stats.movementspeed)
			movement:set_path(dirpath)
			movement:set_snap_to_grid(true)
			movement:set_ignore_obstacles(true)
			movement:start(self)

			function movement.on_obstacle_reached(movement)
				Effects.SimpleTimer(self.entitydata, 200, function() self:resetstate() end)
			end
			function movement.on_finished(movement)
				Effects.SimpleTimer(self.entitydata, 200, function() self:resetstate() end)
			end
		else
			self:gotowards(target)
		end
	end
end

function enemy:gotowards(target)
	local movement = sol.movement.create("target") -- "path_finding")
	movement:set_speed(self.entitydata.stats.movementspeed)
	movement:set_target(target)
	movement:set_smooth(true)
	movement:start(self)
end

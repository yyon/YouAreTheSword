local class = require "middleclass"

EntityData = class("EntityData")

-- import all of the abilities
SwordAbility = require "abilities/sword"
TransformAbility = require "abilities/swordtransform"
ShieldAbility = require "abilities/shield"
ChargeAbility = require "abilities/charge"
ShieldBashAbility = require "abilities/shieldbash"
BombThrowAbility = require "abilities/throwbomb"
GrapplingHookAbility = require "abilities/grapplinghook"
LightningAbility = require "abilities/lightning"
FireballAbility = require "abilities/fireball"
EarthquakeAbility = require "abilities/earthquake"
BlackholeAbility = require "abilities/blackhole"
HealAbility = require "abilities/heal"
HealExplosionAbility = require "abilities/healexplosion"
AngelSummonAbility = require "abilities/angelsummon"
NormalAbility = require "abilities/normalattack"
SidestepAbility = require "abilities/sidestep"
TeleportAbility = require "abilities/teleport"
BodyDoubleAbility = require "abilities/bodydouble"
StealthAbility = require "abilities/stealth"
BackstabAbility = require "abilities/backstab"
TauntAbility = require "abilities/tauntability"
StompAbility = require "abilities/stomp"
NothingAbility = require "abilities/nothing"
BoulderAbility = require "abilities/boulder"
FiringBowAbility = require "abilities/firingBow"
TentacleAbility = require "abilities/tentacles"
PossessAbility = require "abilities/possess"
FireballConeAbility = require "abilities/fireballcone"
TrapsAbility = require "abilities/throwtraps"
SpaceShipProjectileAbility = require "abilities/spaceshipprojectile"
SpaceShipProjectile2Ability = require "abilities/spaceshipproj2"
SpaceShipProjectile3Ability = require "abilities/spaceshipproj3"
SpaceShipProjectile4Ability = require "abilities/spaceshipproj4"
SpaceShipProjectile5Ability = require "abilities/spaceshipproj5"
SpaceShipProjectile6Ability = require "abilities/spaceshipproj6"
GunAbility = require "abilities/gun"

Effects = require "enemies/effect"

local math = require "math"

function EntityData:log(...)
	-- print something in chat using a different color for each person
	
	colstart = ""
	colend = ""
	if self.getlogcolor ~= nil then
		colstart = string.char(27) .. '[' .. self:getlogcolor() .. 'm'
		colend = string.char(27) .. '[' .. "0" .. 'm'
	end

	print(colstart .. self.theclass, ...)
	io.write(colend)
end
function EntityData:getlogcolor()
	return "92"
end

--local maxhealth

function getrandomfromlist(l)
	index = math.random(1,#l)
	return l[index]
end

function EntityData:initialize(entity, class, main_sprite, life, team, swordabilities, transformabilities, blockabilities, specialabilities, stats)
	-- called when entitydata is created
	
	self.entity = entity
	self.theclass = class
	self.main_sprite = main_sprite
	self.life = life
	self.maxlife = self.life
	self.team = team
	self.swordability = getrandomfromlist(swordabilities)
	self.transformability = getrandomfromlist(transformabilities)
	self.blockability = getrandomfromlist(blockabilities)
	self.specialability = getrandomfromlist(specialabilities)
	self.effects = {}
	self.positionlisteners = {}

	if stats.damage == nil then
		stats.damage = 1
	end
	if stats.defense == nil then
		stats.defense = 0.3
	end
	if stats.movementspeed == nil then
		stats.movementspeed = 128
	end
	if stats.warmup == nil then
		stats.warmup = 1
	end
	if stats.cooldown == nil then
		stats.cooldown = 1
	end
	self.originalstats = stats
	self.stats = stats
end

--[[
function EntityData:createfromclass(entity, class)
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
--]]

function EntityData:applytoentity()
	-- changes entities appearance to reflect self
	self.entity.entitydata = self
	self.entity.team = self.team

	if self.entity.ishero then
		self.entity:set_tunic_sprite_id(self.main_sprite)
	else
		self.entity:load_entitydata()
	end

	self:updatemovementspeed()
end

function EntityData:updatechangepos(x, y, layer)
	for index, value in pairs(self.positionlisteners) do
		if value ~= nil then
			value(x, y, layer)
		end
	end
end

function EntityData:updatemovementspeed()
	if self.entity.ishero then
		self.entity:set_walking_speed(self.stats.movementspeed)
	end
end

function EntityData:bepossessedbyhero()
	-- control this entitydata

	local hero = self.entity:get_game():get_hero()

	hero.souls = hero.souls + 1
	if hero.souls > 1 then hero.souls = 1 end

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
	
	--TODO: re-freeze hero
--	if self:getfrozen() ~= nil then
--		self:getfrozen():freeze()
--	end

end

function EntityData:unpossess()
	-- create NPC entity for entitydata

	self.entity.is_possessing = false

	local hero = self.entity:get_game():get_hero()

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

function EntityData:cantarget(entitydata, canbeonsameteam)
--	print(debug.traceback())

	-- is this entitydata a person which can be attacked?
	
	if entitydata == nil then
--		self:log("can't target", entitydata, "because entitydata nil")
		return false
	end
	
	if entitydata.entity == nil then
		return false
	end
	
	if entitydata == self and not canbeonsameteam then
--		self:log("can't target", entitydata, "because self-targeting")
		return false
	end

	if entitydata.team == self.team and not canbeonsameteam then
--		self:log("can't target", entitydata, "because same team")
		return false
	end
	
	if entitydata.caught then
		return false
	end

	if not entitydata:isvisible() and not self.entity.ishero then
--		self:log("can't target", entitydata, "because invisible")
		return false
	end

	return true
end

function EntityData:cantargetentity(entity)
	-- is this entity a person which can be attacked?
	
	if entity == nil then
--		self:log("can't target", entitydata, "because entity nil")
		return false
	end

	return self:cantarget(entity.entitydata)
end

function EntityData:isvisible()
	-- can be seen

	if self.entity.ishero and not self.entity.is_possessing then
		return false
	end
	
	if self.stealth then
		return false
	end
	
	return true
end

function EntityData:getotherentities()
	-- return an iterator of all other people on the map
	-- does not include self
	-- usage: for otherentitydata in entitydata:getotherentities()
	
	if self.entity == nil then print(debug.traceback()) end
	
	local map = self.entity:get_map()
	local heroentity = map:get_hero()
	local saidhero = false
	if self.entity.ishero then
		saidhero = true
	end
	if heroentity.entitydata == nil then
		saidhero = true
	end
	local entityiter, iterstate, lastentity = map:get_entities("")

	iterfunction = function()
		if saidhero == false then
			saidhero = true
			return heroentity.entitydata
		else
			while true do
				newentity, somethingboolean = entityiter(iterstate, lastentity)
				lastentity = newentity
				if newentity == nil then
					return nil
				end
				if newentity.entitydata ~= nil then
					newentitydata = newentity.entitydata
					if newentitydata ~= self and newentitydata ~= heroentity.entitydata then
						return newentitydata
					end
				end
			end
		end
	end
	return iterfunction
end

function EntityData:getability(ability)
	-- string to object
	if ability == "normal" then
		return self.swordability
	elseif ability == "swordtransform" then
		return self.transformability
	elseif ability == "block" then
		return self.blockability
	elseif ability == "special" then
		return self.specialability
	end
end

function EntityData:startability(ability, ...)
	-- call this to use an ability
	-- example: entitydata:startability("special")
	
	if self.usingability == nil then
		actualability = self:getability(ability)
		if actualability.canuse then
			actualability.abilitytype = ability
			actualability:start(...)
--			self:log("Ability:", actualability.name)
			return actualability
		end
	end
end

function EntityData:endability(ability, ...)
	-- stop using a certain ability
	
	if self.usingability ~= nil then
		if self.usingability == self:getability(ability) then
			self.usingability:finish(...)
		end
	end
end

function EntityData:keyrelease(ability)
	-- keyboardrelease -> this method -> calls ability's keyrelease method
	
	if self.usingability ~= nil then
		if self.usingability == self:getability(ability) then
			self.usingability:keyrelease()
		end
	end
end

function EntityData:tickability(...)
	-- not really used
	
	if self.usingability ~= nil then
		self.usingability:tick(...)
	end
end

function EntityData:canuseability(ability)
	-- can you use this ability?
	-- for example, is cooldown finished? is another ability currently being used?
	
	actualability = self:getability(ability)
	return actualability.canuse
end

function EntityData:withinrange(ability, entitydata)
	-- if an entity can be attacked using the ability
	-- this is to help the AI decide when to attack
	
	ability = self:getability(ability)
	range = ability.range
	d = self.entity:get_distance(entitydata.entity)
	withinrange = (d <= range)
	return withinrange
end

function EntityData:getdirection()
	-- facing direction
	
	if self.entity.ishero then
		return self.entity:get_direction()
	else
		return self.entity.direction
	end
end

function EntityData:setdirection(d)
	if self.entity.ishero then
		return self.entity:set_direction(d)
	else
		return self.entity:setdirection(d)
	end
end
	

function EntityData:setanimation(anim)
	-- set current sprite animation
	
	if self.entity.ishero then
		self.entity:set_animation(anim)
	else
		self.entity.main_sprite:set_animation(anim)
		self.entity.main_sprite:set_paused(false)
	end
end

--[[
function EntityData:freeze(type, priority, cancelfunction)
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
			self.entity:tick(self.entity.frozenstate)
		end

		self:log("freezing", type)

		return true
	else
		self:log("couldn't freeze", type, self.freezetype)
	end

	return false
end

function EntityData:unfreeze(type, dotick)
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
--]]

--[[
function EntityData:freeze()
	Effects.FreezeEffect(self)
end

function EntityData:unfreeze()
	if self:getfrozen() ~= nil then
		self:getfrozen():remove()
	else
		self:log("Tried to unfreeze when not frozen")
	end
end

function EntityData:getfrozen()
--	return Effects.FreezeEffect:get(self)
	for index, value in pairs(self.freezeeffects) do
		if index.active then
			return index
		end
	end
end
--]]

function EntityData:dodamage(target, damage, aspects)
	-- call this to damage the target
	
	if self.entity == nil then return end
	
	if aspects == nil then
		aspects = {}
	end

	if aspects.natural then
		aspects.sameteam = true
	end
	
	if not self:cantarget(target, aspects.sameteam) then
		return
	end
	
	if target.isbeingknockedback then
		return
	end

	if target.usingability ~= nil and not aspects.dontblock then
		damage, aspects = target.usingability:blockdamage(self, damage, aspects)
	end

	if aspects.donothing then
		return
	end
	
	--reverse cancel
	if aspects.reversecancel ~= nil and not aspects.fromentity then
		target:dodamage(self, 0, {knockback=0, stun=aspects.reversecancel, dontblock=true})
		return
	end

	-- aspects
	if aspects.knockback == nil then
		aspects.knockback = 500
	end
	if aspects.fromentity == nil then
		aspects.fromentity = self.entity
	end

	if aspects.electric ~= nil then
--		aspects.knockback = 0

--		stuneffect = Effects.StunEffect(target, aspects.stun)
--		electriceffect = Effects.ElectricalEffect(target, aspects.stun)
--		if target:getfrozen() == nil then
			electricstuneffect = Effects.ElectricalStunEffect(target, aspects.electric)
--		end
	end
	if aspects.stun ~= nil then
--		aspects.knockback = 0

--		stuneffect = Effects.StunEffect(target, aspects.stun)
--		electriceffect = Effects.ElectricalEffect(target, aspects.stun)
--		if target:getfrozen() == nil then
			stun = Effects.StunEffect(target, aspects.stun)
--		end
	end
	if aspects.fire ~= nil then
		fireeffect = Effects.FireEffect(target, aspects.fire)
	end
	if aspects.poison ~= nil then
		poisoneffect = Effects.PoisonWeaknessEffect(target, aspects.poison.weakness, aspects.poison.time)
	end
	if aspects.flame ~= nil then
		aspects.knockback = 0
	end
	if aspects.method ~= nil then
		aspects.method()
	end
	if aspects.holy ~= nil then
		if target.undead then
			damage = damage + 5
		end
	end
	if aspects.buffattack ~= nil then
		aspects.buffattack()
	end
	if aspects.debuffattack ~= nil then
		aspects.debuffattack()
	end
	

	--cancel enemy's ability
	if aspects.natural == nil and aspects.dontcancel == nil and target.cantcancel == nil then
		if target.usingability ~= nil then
			target.usingability:cancel()
		end
	end

	-- do damage
	damage = damage * self.stats.damage
	
	if self.entity.ishero then
		if not aspects.natural then
			souls = self.entity.souls
			damagemultiplier = souls + 0.5
			damage = damage * damagemultiplier
		end
	end
	if aspects.ap == nil then
		negateddamage = damage * target.stats.defense
		damage = damage - negateddamage
	end

	target.life = target.life - damage
	
	if aspects.lifesteal then
		self.life = self.life + damage
		if self.life > self.maxlife then
			self.life = self.maxlife
		end
	end

	--aggro
	if not target.entity.ishero and target ~= self then
		target.entity.entitytoattack = self
		target.entity.hasbeenhit = true
	end

	--knockback
	if aspects.knockback ~= 0 and target.cantcancel == nil then
--		if target:getfrozen() == nil then
			angle = nil
			if aspects.knockbackrandomangle then
				angle = math.random() * 2 * math.pi
			end
			if aspects.directionalknockback then
				angle = aspects.fromentity:get_direction() * math.pi / 2
			end
			kbe = KnockBackEffect:new(target, aspects.fromentity, aspects.knockback, angle)
--[[
			if target.entity.ishero then
				target:freeze()
				local x, y = target.entity:get_position()
				local angle = target.entity:get_angle(self.entity) + math.pi
				local movement = sol.movement.create("straight")
				movement:set_speed(128)
				movement:set_angle(angle)
				movement:set_max_distance(knockback)
				movement:set_smooth(true)
				movement:start(target.entity)
				function movement:on_finished()
					target:unfreeze()
				end
			else
				target.entity:receive_attack_animation(self.entity)
			end
--]]
--		else
--			self:log("already frozen:", self:getfrozen())
--		end
	end

	if target.life <= 0 or aspects.instantdeath then
		target:kill()
	else
		if target.stages ~= nil then
			for stagelife, stagefunct in pairs(target.stages) do
				if target.life/target.maxlife < stagelife then
					print("target", target.theclass, "entered new stage", stagelife)
					stagefunct()
					target:applytoentity()
					target.stages[stagelife] = nil
					break
				end
			end
		end
	end
end

function EntityData:physicaleffectanimation(name, time)
	-- Use Effects.<some physical effect> intead
--[[
	-- TODO: put into generic time-based effect thingy
	entity = self.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()

	paentity = map:create_custom_entity({model="physicaleffect", x=x, y=y, layer=layer, direction=0, width=w, height=h})

	paentity:start(self, name, time)

	return paentity
--]]

end

function EntityData:kill()
	-- adventurer/monster is killed
	if self.entity == nil then return end
	
	game = self.entity:get_game()
	if game.nodeaths then
		return
	end
	
	theishero = self.entity.ishero

	if theishero then
		-- drop sword
		self:drop()
		
		newentity = self:unpossess()
		newentity.entitydata:kill()
	else
--		self:freeze()
		freezeeffect = Effects.FreezeEffect:new(self)
		self.entity:set_life(0)
	end

	for key, effect in pairs(self.effects) do
		effect:forceremove()
	end
	
	if self.entity ~= nil then
		self.entity.entitydata = nil
		
		if self:getremainingadventurers(true) <= 0 then
			self:swordkill()
		end
	end
	
	self.entity = nil
end

function EntityData:dropsword()
	hero = self.entity
	
	if not hero.ishero then return end	
	if hero.isthrown then return end
	if hero.isdropped then return end
	
	self:dodamage(self, 0, {sameteam=true}) -- cancel ability
	
	self:drop()
	
	newentity = self:unpossess()
	
	for key, effect in pairs(self.effects) do
		effect:forceremove()
	end
end

function EntityData:swordkill()
	-- sword health runs out
	
	game = self.entity:get_game()
	if game.nodeaths then
		return
	end
	hero = game:get_hero()
	
	print("HERO DEATH!")
	
	for key, effect in pairs(self.effects) do
		effect:forceremove()
	end
	
	hero.swordhealth = hero.maxswordhealth
	
--	-- TODO: make this work
--	self.entity:teleport(self.entity:get_map():get_id())
	game.hasended = true
end

function EntityData:drop(hero)
	-- sword is dropped on the ground if person holding demon sword is killed
	
	if hero == nil then hero = self.entity end
	if hero.ishero then
		hero.entitydata = nil
		hero:set_animation("stopped")
		hero:set_tunic_sprite_id("abilities/droppedsword")
		hero:freeze()
		hero.isdropped = true
	end
end

function EntityData:throwsword(entitydata2)
	-- throws the demon sword to another person
	
--	self:log("going to throw to", entitydata2.class)
	if self.entity.ishero then
		if self.usingability ~= nil then
			return
		end

		if hero.isthrown then
			return
		end

		if entitydata2 == nil then
			return
		end

		if not entitydata2.entity:exists() then
			return
		end

		if not entitydata2.entity.hasbeeninitialized then
			return
		end
		
		if entitydata2.effects["possess"] then
			entitydata2.effects["possess"]:remove()
		end

		sol.audio.play_sound("swing" .. math.random(1,3))
		
		hero.isthrown = true

		hero = self.entity
		hero.isthrown = true
		hero:freeze()

		newentity = self:unpossess()

		hero:set_tunic_sprite_id("abilities/thrownsword")
		hero:set_animation("stopped")

		hero:stop_movement()

		local movement = sol.movement.create("target")
		movement:set_speed(1000)
		movement:set_target(entitydata2.entity)
		movement:start(hero)

		movement:set_ignore_obstacles()
--[[
		function movement:on_obstacle_reached()
			movement:stop()
			EntityData:drop(hero)
		end
--]]
		local hero = hero

		function movement:on_finished()
			entitydata2:bepossessedbyhero()
		end
		
		function movement:on_position_changed()
			d = hero:get_distance(entitydata2.entity)
			if d < 30 then
				self:stop()
				entitydata2:bepossessedbyhero()
			end
		end
	end
end

function EntityData:getrandom()
	-- get random person on map
	-- does not include self
	
	require "math"

	map = game:get_map()
	hero = game:get_hero()

	entitieslist = {}
	for entitydata in self:getotherentities() do
		entity = entitydata.entity
		entitieslist[#entitieslist+1] = entity
	end

	entity = entitieslist[math.random(#entitieslist)]
	return entity
end

function EntityData:throwrandom()
	-- throw sword to random person
	entity = self:getrandom()

	if entity ~= nil then
		if hero.entitydata ~= nil then
			hero.entitydata:throwsword(entity.entitydata)
		end
--		hero.entitydata:unpossess()
--		entity.entitydata:bepossessedbyhero()
	end
end

function EntityData:getstraightestentity(x, y)
	-- If you want to aim at an entity using the angle between the entity and the mouse, this will find the entity with the closest angle
	-- getclosestentity is used instead (returns slightly different result)
	
	local math = require "math"

	angle = self.entity:get_angle(x, y)

	minangle = 999
	minentity = nil

	map = game:get_map()
	hero = self.entity

	for entitydata in self:getotherentities() do
		entity = entitydata.entity
		angle2 = self.entity:get_angle(entity)
		d = math.abs(angle - angle2)
		if d < minangle then
			minangle = d
			minentity = entity.entitydata
		end
	end

	return minentity
end

function EntityData:getclosestentity(x, y, isenemy, funct)
	-- find person closest to a point
	-- does not include self
	-- can be used to find person closest to mouse pointer (used with gettargetpos)
	
	mindist = 99999
	minentity = nil

	map = game:get_map()
	hero = self.entity

	for entitydata in self:getotherentities() do
		if not isenemy or self:cantarget(entitydata) then
			if (funct == nil) or (funct(entitydata) == true) then
				entity = entitydata.entity
				d = entity:get_distance(x, y)
				if d < mindist then
					mindist = d
					minentity = entity.entitydata
				end
			end
		end
	end

	return minentity
end

function EntityData:throwclosest(mousex, mousey)
	-- throw the sword to the person closest to the mouse
	
--[[
	for entity in self.entity:get_map():get_entities("") do
		if entity.entitydata ~= nil then
			x, y = entity:get_position()
			entity.entitydata:log(x, y)
		end
	end
	print("closest", mousex, mousey, selelse

--]]
	entity = self:getclosestentity(x, y, false, function(entitydata) return not entitydata.cantpossess end)
	if entity ~= nil then
		if hero.entitydata ~= nil then
			hero.entitydata:throwsword(entity)
		end
	end
end

function EntityData:gettargetpos()
	-- returns the mouse pointer position if hero
	-- returns AI aiming position if AI
	
	if self.entity.ishero then
		map = self.entity:get_map()
		mousex, mousey = sol.input.get_mouse_position()
		cx, cy, cw, ch = map:get_camera_position()
		x, y = mousex + cx, mousey + cy
		return x, y
--		return self.entity.targetx, self.entity.targety
	else
		target = self.entity.lasttarget
		if target.entity == nil then target = self.entity:targetenemy() end
		if target ~= nil then
			if self.usingability ~= nil and self.usingability.abilitytype == "block" then
				x, y = self.entity:getblockposition(target)
			else
				x, y = target.entity:get_position()
			end
			return x, y
		end
	end
end

function EntityData:getremainingmonsters()
	enemiesremaining = 0
	
	if self.team == "monster" then
		enemiesremaining = 1
	end
	
	for entitydata in self:getotherentities() do
		if entitydata.team == "monster" then
			enemiesremaining = enemiesremaining + 1
		end
	end
	
	return enemiesremaining
end

function EntityData:getremainingadventurers(dontcountself)
	enemiesremaining = 0
	
	if not dontcountself then
		if self.team == "adventurer" and self.entity ~= nil then
			enemiesremaining = 1
		end
	end
	
	for entitydata in self:getotherentities() do
		if entitydata.team == "adventurer" then
			enemiesremaining = enemiesremaining + 1
		end
	end
	
	return enemiesremaining
end

function EntityData:canmoveto(tox, toy)
	entity = self.entity
	
	local d = entity:get_distance(tox, toy)
	local x, y = entity:get_position()
	local dx, dy = tox-x, toy-y
	canmove = true
	for i=0,d,20 do
		local p = i/d
		newdx, newdy = dx*p, dy*p
		if entity:test_obstacles(newdx, newdy) then
			canmove = false
			
			break
		end
	end
	
	if entity:test_obstacles(dx, dy) then
		canmove = false
	end
	
	return canmove
end



function EntityData:totable()
	return {
		classname = self.class.name,
		life=self.life,
		maxlife=self.maxlife,
		team=self.team,
		swordability=self.swordability.name,
		transformability=self.transformability.name,
		blockability=self.blockability.name,
		specialability = self.specialability.name
	}
end

function EntityData.static:fromtable(table, entity)
	for _, class in pairs(allclasses) do
		if class.name == table.classname then
			theclass = class
			break
		end
	end
	if theclass ~= nil then
		entitydata = theclass:new(entity)
		entitydata.entity = entity
		entitydata:applytoentity()
		
		for index, ability in pairs(entitydata.normalabilities) do
			if ability.name == table.swordability then
				entitydata.swordability = ability
			end
		end
		for index, ability in pairs(entitydata.transformabilities) do
			if ability.name == table.transformability then
				entitydata.transformability = ability
			end
		end
		for index, ability in pairs(entitydata.blockabilities) do
			if ability.name == table.blockability then
				entitydata.blockability = ability
			end
		end
		for index, ability in pairs(entitydata.specialabilities) do
			if ability.name == table.specialability then
				entitydata.specialability = ability
			end
		end
		
		entitydata.life = table.life
		entitydata.maxlife = table.maxlife
		entitydata.team = table.team
		
		return entitydata
	end
end

-- Actual classes

allclasses = {EntityData=EntityData}

-- Test classes:

yellowclass = EntityData:subclass("yellowclass")
allclasses.yellowclass = yellowclass

function yellowclass:initialize(entity)
	class = "yellow"
	main_sprite = "adventurers/guy2"
	life = 10
	team = "yellow" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {FireballAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "holy")}
	blockabilities = {TeleportAbility:new(self)}
	specialabilities = {StealthAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

greenclass = EntityData:subclass("greenclass")
allclasses.greenclass = greenclass

function greenclass:initialize(entity)
	class = "green"
	main_sprite = "adventurers/guy3"
	life = 10
	team = "green" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {HealAbility:new(self), FireballAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "poison")}
	blockabilities = {ShieldAbility:new(self)}
	specialabilities = {BombThrowAbility:new(self), GrapplingHookAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

-- Adventurers:

knightclass = EntityData:subclass("knightclass")
allclasses.knightclass = knightclass

function knightclass:initialize(entity)
	class = "knight"
	main_sprite = "adventurers/knight"
	life = 10
	team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {SwordAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "ap")}
	blockabilities = {ShieldAbility:new(self)}
	specialabilities = {ChargeAbility:new(self), ShieldBashAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

mageclass = EntityData:subclass("mageclass")
allclasses.mageclass = mageclass

function mageclass:initialize(entity)
	class = "mage"
	main_sprite = "adventurers/mage"
	life = 10
	team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {SwordAbility:new(self), FireballAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "electric"), TransformAbility:new(self, "fire"), TransformAbility:new(self, "poison")}
	blockabilities = {TeleportAbility:new(self)}
	specialabilities = {LightningAbility:new(self), EarthquakeAbility:new(self), BlackHoleAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

clericclass = EntityData:subclass("clericclass")
allclasses.clericclass = clericclass

function clericclass:initialize(entity)
	class = "cleric"
	main_sprite = "adventurers/cleric"
	life = 10
	team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {SwordAbility:new(self), HealAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "holy"), TransformAbility:new(self, "lifesteal")}
	blockabilities = {SidestepAbility:new(self)}
	specialabilities = {AngelSummonAbility:new(self), HealExplosionAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

rogueclass = EntityData:subclass("rogueclass")
allclasses.rogueclass = rogueclass

function rogueclass:initialize(entity)
	class = "rogue"
	main_sprite = "adventurers/rogue"
	life = 10
	team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {SwordAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "dagger"), TransformAbility:new(self, "poison")}
	blockabilities = {SidestepAbility:new(self), BodyDoubleAbility:new(self)}
	specialabilities = {TrapsAbility:new(self), BackstabAbility:new(self), StealthAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

bardclass = EntityData:subclass("bardclass")
allclasses.bardclass = bardclass

function bardclass:initialize(entity)
	class = "bard"
	main_sprite = "adventurers/bard"
	life = 10
	team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {SwordAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "dagger")}
	blockabilities = {SidestepAbility:new(self)}
	specialabilities = {TauntAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

berserkerclass = EntityData:subclass("berserkerclass")
allclasses.berserkerclass = berserkerclass

function berserkerclass:initialize(entity)
	class = "berserker"
	main_sprite = "adventurers/berserker"
	life = 10
	team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {SwordAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "damage")}
	blockabilities = {ShieldAbility:new(self)}
	specialabilities = {StompAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

archerclass = EntityData:subclass("archerclass")
allclasses.archerclass = archerclass

function archerclass:initialize(entity)
	class = "archer"
	main_sprite = "adventurers/archer"
	life = 10
	team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {FiringBowAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "dagger")}
	blockabilities = {SidestepAbility:new(self)}
	specialabilities = {GrapplingHookAbility:new(self), BombThrowAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

-- Monsters:

skeletonclass = EntityData:subclass("skeletonclass")
allclasses.skeletonclass = skeletonclass

function skeletonclass:initialize(entity)
	class = "skeleton"
	main_sprite = "monsters/skeleton"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {FiringBowAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "ap"), TransformAbility:new(self, "damage")}
	blockabilities = {ShieldAbility:new(self)}
	specialabilities = {ShieldBashAbility:new(self), GrapplingHookAbility:new(self)}
	basestats = {}
	self.undead = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

orcclass = EntityData:subclass("orcclass")
allclasses.orcclass = orcclass

function orcclass:initialize(entity)
	class = "orc"
	main_sprite = "monsters/orc"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {SwordAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "ap"), TransformAbility:new(self, "damage")}
	blockabilities = {ShieldAbility:new(self)}
	specialabilities = {ShieldBashAbility:new(self), BombThrowAbility:new(self)}
	basestats = {damage=2, warmup=1.5}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

evilmageclass = EntityData:subclass("evilmageclass")
allclasses.evilmageclass = evilmageclass

function evilmageclass:initialize(entity)
	class = "evil mage"
	main_sprite = "monsters/evilmage"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {FireballAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "electric"), TransformAbility:new(self, "fire"), TransformAbility:new(self, "poison")}
	blockabilities = {TeleportAbility:new(self)}
	specialabilities = {LightningAbility:new(self), EarthquakeAbility:new(self), BlackHoleAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

spiderclass = EntityData:subclass("spiderclass")
allclasses.spiderclass = spiderclass

function spiderclass:initialize(entity)
	class = "spider"
	main_sprite = "monsters/spiders/spider" .. string.format("%02d", math.random(1,11))
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	aspects = {poison = {weakness=0.4, time=5000}}
	normalabilities = {NormalAbility:new(self, "sword", aspects)}
	transformabilities = {TransformAbility:new(self, "poison")}
	blockabilities = {SidestepAbility:new(self)}
	specialabilities = {BackstabAbility:new(self)}
	basestats = {}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

mechclass = EntityData:subclass("mechclass")
allclasses.mechclass = mechclass

function mechclass:initialize(entity)
	class = "mech"
	main_sprite = "monsters/mech"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {GunAbility:new(self)}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {NothingAbility:new(self)}
	specialabilities = {NothingAbility:new(self)}
	basestats = {}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

beetleclass = EntityData:subclass("beetleclass")
allclasses.beetleclass = beetleclass

function beetleclass:initialize(entity)
	class = "beetle"
	main_sprite = "monsters/beetle"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {NormalAbility:new(self)}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {SidestepAbility:new(self)}
	specialabilities = {NothingAbility:new(self)}
	basestats = {}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

ghostclass = EntityData:subclass("ghostclass")
allclasses.ghostclass = ghostclass

function ghostclass:initialize(entity)
	class = "ghost"
	main_sprite = "monsters/ghost"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {FireballAbility:new(self)}
	transformabilities = {SwordAbility:new(self, "fire")}
	blockabilities = {TeleportAbility:new(self)}
	specialabilities = {StealthAbility:new(self), BlackholeAbility:new(self)}
	basestats = {movementspeed=100}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

flowerclass = EntityData:subclass("flowerclass")
allclasses.flowerclass = flowerclass

function flowerclass:initialize(entity)
	class = "flower"
	main_sprite = "monsters/flower"
	life = 20
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {FireballAbility:new(self)}
	transformabilities = {SwordAbility:new(self, "fire")}
	blockabilities = {NothingAbility:new(self)}
	specialabilities = {GrapplingHookAbility:new(self)}
	basestats = {movementspeed=0, cooldown=2}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

batclass = EntityData:subclass("batclass")
allclasses.batclass = batclass

function batclass:initialize(entity)
	class = "bat"
	main_sprite = "monsters/bat"
	life = 5
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {NormalAbility:new(self, "casting"), HealAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "lifesteal")}
	blockabilities = {SidestepAbility:new(self)}
	specialabilities = {HealExplosionAbility:new(self)}
	basestats = {movementspeed=200, damage=0.8}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

beeclass = EntityData:subclass("beeclass")
allclasses.beeclass = beeclass

function beeclass:initialize(entity)
	class = "bee"
	main_sprite = "monsters/bee"
	life = 5
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {NormalAbility:new(self, "casting")}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {SidestepAbility:new(self)}
	specialabilities = {BackstabAbility:new(self)}
	basestats = {movementspeed=200, damage=0.8}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

wormclass = EntityData:subclass("wormclass")
allclasses.wormclass = wormclass

function wormclass:initialize(entity)
	class = "worm"
	main_sprite = "monsters/big_worm"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {NormalAbility:new(self, "casting")}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {NothingAbility:new(self)}
	specialabilities = {NothingAbility:new(self)}
	basestats = {damage=2}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

slimeclass = EntityData:subclass("slimeclass")
allclasses.slimeclass = slimeclass

function slimeclass:initialize(entity)
	class = "slime"
	main_sprite = "monsters/slime"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {NormalAbility:new(self, "casting")}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {NothingAbility:new(self)}
	specialabilities = {NothingAbility:new(self)}
	basestats = {damage=0.5}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

eyeclass = EntityData:subclass("eyeclass")
allclasses.eyeclass = eyeclass

function eyeclass:initialize(entity)
	class = "floating eyeball"
	main_sprite = "monsters/eyeball"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {FireballAbility:new(self, "casting")}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {TeleportAbility:new(self)}
	specialabilities = {BlackholeAbility:new(self)}
	basestats = {warmup=0.5, cooldown=0.5}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

maskmanclass = EntityData:subclass("maskmanclass")
allclasses.maskmanclass = maskmanclass

function maskmanclass:initialize(entity)
	class = "mask man"
	main_sprite = "monsters/maskman"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {NormalAbility:new(self, "casting")}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {TeleportAbility:new(self)}
	specialabilities = {StompAbility:new(self)}
	basestats = {}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

wolfclass = EntityData:subclass("wolfclass")
allclasses.wolfclass = wolfclass

function wolfclass:initialize(entity)
	class = "wolf"
	main_sprite = "monsters/wolf"
	life = 10
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {NormalAbility:new(self, "sword")}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {NothingAbility:new(self)}
	specialabilities = {NothingAbility:new(self)}
	basestats = {}
	self.cantdraweyes = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

-- Bosses

spaceshipboss = EntityData:subclass("spaceshipboss")
allclasses.spaceshipboss = spaceshipboss

function spaceshipboss:initialize(entity)
	class = "Space Ship (Boss)"
	main_sprite = "bosses/spaceship-1"
	life = 200
	team = "boss" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {SpaceShipProjectileAbility:new(self)}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {NothingAbility:new(self)}
	specialabilities = {SpaceShipProjectile2Ability:new(self)}
	basestats = {}
	self.cantcancel = true
	self.cantpossess=true
	
	self.stages = {[0.66] = function() self:stage2() end, [0.33] = function() self:stage3() end}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

function spaceshipboss:stage2()
	self.main_sprite = "bosses/spaceship-2"
	self.swordability = SpaceShipProjectile6Ability:new(self)
	self.specialability = SpaceShipProjectile4Ability:new(self)
end

function spaceshipboss:stage3()
	self.main_sprite = "bosses/spaceship-3"
	self.swordability = SpaceShipProjectile3Ability:new(self)
	self.specialability = SpaceShipProjectile5Ability:new(self)
end

mageboss = EntityData:subclass("mageboss")
allclasses.mageboss = mageboss

function mageboss:initialize(entity)
	class = "Mage (Boss)"
	main_sprite = "bosses/mage-1"
	life = 200
	team = "boss" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {NothingAbility:new(self)}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {NothingAbility:new(self)}
	specialabilities = {TentacleAbility:new(self)}
	basestats = {movementspeed=0}
	self.cantpossess=true
	self.cantcancel = true
	
	self.stages = {[0.66] = function() self:stage2() end, [0.33] = function() self:stage3() end}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

function mageboss:stage2()
	self.main_sprite = "bosses/mage-2"
	self.stats.movementspeed = 50
	self.swordability = FireballAbility:new(self)
	self.specialability = NothingAbility:new(self)
end

function mageboss:stage3()
	self.main_sprite = "bosses/mage-3"
	self.blockability = TeleportAbility:new(self)
	self.specialability = TentacleAbility:new(self)
end


dunsmurclass = EntityData:subclass("dunsmurclass")
allclasses.dunsmurclass = dunsmurclass

function dunsmurclass:initialize(entity)
	class = "Duns Mur"
	main_sprite = "bosses/dunsmur-1"
	life = 300
	team = "dunsmur" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {SwordAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "lifesteal")}
	blockabilities = {ShieldAbility:new(self)}
	specialabilities = {PossessAbility:new(self)}
	basestats = {}
	self.cantcancel = true
	
	self.stages = {[0.66] = function() self:stage2() end, [0.33] = function() self:stage3() end}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

function dunsmurclass:stage2()
	self.main_sprite = "bosses/dunsmur-2"
	self.swordability = PossessAbility:new(self)
	self.specialability = FireballConeAbility:new(self)
end

function dunsmurclass:stage3()
	self.main_sprite = "bosses/dunsmur-3"
	self.swordability = PossessAbility:new(self)
	self.specialability = BoulderAbility:new(self)
end

-- Summoned:

angelclass = EntityData:subclass("angelclass")
allclasses.angelclass = angelclass

function angelclass:initialize(entity)
	class = "angel"
	main_sprite = "adventurers/angel"
	life = 5
	team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {SwordAbility:new(self)}
	transformabilities = {TransformAbility:new(self, "holy")}
	blockabilities = {ShieldAbility:new(self)}
	specialabilities = {HealExplosionAbility:new(self)}
	basestats = {}
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

dummyclass = EntityData:subclass("dummyclass")
allclasses.dummyclass = dummyclass

function dummyclass:initialize(entity)
	class = "baddummyclass"
	main_sprite = "adventurers/dummy"
	life = 5
	team = "monster" -- should be either "adventurer" or "monster" in the final version
	normalabilities = {NothingAbility:new(self)}
	transformabilities = {NothingAbility:new(self)}
	blockabilities = {NothingAbility:new(self)}
	specialabilities = {NothingAbility:new(self)}
	basestats = {movementspeed=0}
	self.dontmove = true
	
	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

return allclasses
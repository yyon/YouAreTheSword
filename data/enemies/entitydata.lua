local class = require "middleclass"

local EntityData = class("EntityData")

-- import all of the abilities
local RageAbility = require "abilities/rage"
local HasteAbility = require "abilities/haste"
local NetAbility = require "abilities/net"
local SwordAbility = require "abilities/sword"
local TransformAbility = require "abilities/swordtransform"
local ShieldAbility = require "abilities/shield"
local ChargeAbility = require "abilities/charge"
local ShieldBashAbility = require "abilities/shieldbash"
local BombThrowAbility = require "abilities/throwbomb"
local GrapplingHookAbility = require "abilities/grapplinghook"
local LightningAbility = require "abilities/lightning"
local FireballAbility = require "abilities/fireball"
local EarthquakeAbility = require "abilities/earthquake"
local BlackholeAbility = require "abilities/blackhole"
local HealAbility = require "abilities/heal"
local HealExplosionAbility = require "abilities/healexplosion"
local AngelSummonAbility = require "abilities/angelsummon"
local NormalAbility = require "abilities/normalattack"
local SidestepAbility = require "abilities/sidestep"
local TeleportAbility = require "abilities/teleport"
local BodyDoubleAbility = require "abilities/bodydouble"
local StealthAbility = require "abilities/stealth"
local BackstabAbility = require "abilities/backstab"
local TauntAbility = require "abilities/tauntability"
local StompAbility = require "abilities/stomp"
local NothingAbility = require "abilities/nothing"
local BoulderAbility = require "abilities/boulder"
local FiringBowAbility = require "abilities/firingBow"
local TentacleAbility = require "abilities/tentacles"
local PossessAbility = require "abilities/possess"
local FireballConeAbility = require "abilities/fireballcone"
local TrapsAbility = require "abilities/throwtraps"
local SpaceShipProjectileAbility = require "abilities/spaceshipprojectile"
local SpaceShipProjectile2Ability = require "abilities/spaceshipproj2"
local SpaceShipProjectile3Ability = require "abilities/spaceshipproj3"
local SpaceShipProjectile4Ability = require "abilities/spaceshipproj4"
local SpaceShipProjectile5Ability = require "abilities/spaceshipproj5"
local SpaceShipProjectile6Ability = require "abilities/spaceshipproj6"
local GunAbility = require "abilities/gun"
local CatKickAbility = require "abilities/catkick"
local CatShootAbility = require "abilities/catshoot"
local LightningBallAbility = require "abilities/lightningball"
local DefenseAbility = require "abilities/defense"
local SeedShootAbility = require "abilities/seedshoot"
local BoomerangAbility = require "abilities/boomerang"

local Effects = require "enemies/effect"

local movementaccuracy = require "scripts/movementaccuracy"

local math = require "math"

function EntityData:log(...)
	-- print something in chat using a different color for each person

	local colstart = ""
	local colend = ""
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

local function getrandomfromlist(l)
	local index = math.random(1,#l)
	return l[index]
end

function EntityData:initialize(entity, theclass, main_sprite, life, team, swordabilities, transformabilities, blockabilities, specialabilities, stats)
	-- called when entitydata is created

	self.entity = entity
	self.theclass = theclass
	self.main_sprite = main_sprite
	self.life = life
	self.maxlife = self.life
	self.souls = 1
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
	
	self.originalstats = {}
	for k, v in pairs(stats) do
		self.originalstats[k] = v
	end
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
	if self.entity == nil then
		return 
	end
	if self.entity.ishero then
		self.entity:set_walking_speed(self.stats.movementspeed)
	else
		if self.entity.movementspeed ~= self.stats.movementspeed then
			self.entity:resetstate()
		end
	end
	self.entity.movementspeed = self.stats.movementspeed
end

function EntityData:bepossessedbyhero()
	-- control this entitydata

	local hero = game:get_hero()

--	hero.souls = hero.souls + 1
--	if hero.souls > 1 then hero.souls = 1 end

	hero:unfreeze()
	hero.isdropped = false
	hero.isthrown = false

--	local map = self.entity:get_map()
--	local hero = map:get_hero()

	hero.entitydata = self

	local isfreezed = false
	local anim
	local movement
	local visible

	self:changemovements(self.entity, hero)

	if self.entity ~= nil then
		hero:set_position(self.entity:get_position())
		hero:set_direction(self.entity.direction)

		isfreezed = self:isfrozen(self.entity)
		anim = self:getanimation()
		movement = self.entity:get_movement()
		visible = self.entity:is_visible()

		self.entity:remove()
	end

	self.entity = hero
	self:applytoentity()

	if isfreezed then
		hero:freeze()
		if movement ~= nil then
			movement:start(hero)
		end
	end
	if anim ~= nil then
		self:setanimation(anim)
	end
	if visible ~= nil then
		hero:set_visible(visible)
	end

	self.entity.is_possessing = true
end

function EntityData:unpossess(name)
	-- create NPC entity for entitydata

	if self.usingability ~= nil then
		self.usingability:locktarget()
	end

	self.entity.is_possessing = false

	local hero = self.entity:get_game():get_hero()

	local anim = self:getanimation()
	local movement = self.entity:get_movement()
	local visible = self.entity:is_visible()

	hero.entitydata = nil

	local map = self.entity:get_map()

	local x, y, layer = self.entity:get_position()

	local d = self.entity:get_direction()

	local newentity = map:create_enemy({
		breed="enemy_constructor",
		layer=layer,
		x=x,
		y=y,
		direction=d,
		name=name
	})


	self.entity = newentity

	if self.entity.ishero then
		print("ERROR: new entity is hero")
	end

	self:applytoentity()

	self.entity:setdirection(d)

	if self:isfrozen(hero) then
		hero:unfreeze()
		self.entity:tick(self.entity.frozenstate)

		if movement ~= nil then
			movement:start(self.entity)
		end
	end

	self:setanimation(anim)
	self.entity:set_visible(visible)

	self:changemovements(hero, newentity)

	if self.usingability ~= nil then
		self.usingability:keyrelease()
	end

	self.entity:tick()

	return self.entity
end

function EntityData:cantarget(entitydata, canbeonsameteam, isattack, onlyonsameteam)
--	print(debug.traceback())

	-- is this entitydata a person which can be attacked?

	if entitydata == nil then
--		self:log("can't target", entitydata, "because entitydata nil")
		return false
	end

	if entitydata.entity == nil then
		return false
	end

	if entitydata == self and not (canbeonsameteam or onlyonsameteam) then
--		self:log("can't target", entitydata, "because self-targeting")
		return false
	end

	if entitydata.team == self.team and not (canbeonsameteam or onlyonsameteam) then
--		self:log("can't target", entitydata, "because same team")
		return false
	end
	
	if onlyonsameteam and entitydata.team ~= self.team then
		return false
	end


	if entitydata.caught then
		return false
	end

--	if not entitydata:isvisible() and not isattack then
--		print("can't target", entitydata, "because invisible")
--		return false
--	end

	return true
end

function EntityData:cantargetentity(entity, canbeonsameteam, isattack, onlyonsameteam)
	-- is this entity a person which can be attacked?

	if entity == nil then
--		self:log("can't target", entitydata, "because entity nil")
		return false
	end

	return self:cantarget(entity.entitydata, canbeonsameteam, isattack, onlyonsameteam)
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

	if self.entity == nil then print(debug.traceback()); return end

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

	local iterfunction = function()
		if saidhero == false then
			saidhero = true
			return heroentity.entitydata
		else
			while true do
				local newentity = entityiter(iterstate, lastentity)
				lastentity = newentity
				if newentity == nil then
					return nil
				end
				if newentity.entitydata ~= nil then
					local newentitydata = newentity.entitydata
					if newentitydata ~= self and newentitydata ~= heroentity.entitydata and newentitydata.entity ~= nil then
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

	if self.usingability == nil and not self:isfrozen() then
		local actualability = self:getability(ability)
		if actualability.canuse then
			actualability.abilitytype = ability
			actualability:start(...)
--			self:log("Ability:", actualability.name)
			return actualability
		end
	elseif self.usingability ~= nil and self.usingability.usingwarmup and self.usingability.abilitytype == ability and self.entity.ishero then
		self.usingability:locktarget()
	end
end

function EntityData:isfrozen(entity)
	if entity == nil then entity = self.entity end
	if entity.ishero then
		return (entity:get_state() == "freezed")
	else
		return (entity.state == entity.frozenstate)
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

	local actualability = self:getability(ability)
	return actualability.canuse
end

function EntityData:withinrange(ability, entitydata)
	-- if an entity can be attacked using the ability
	-- this is to help the AI decide when to attack

	ability = self:getability(ability)
	local range = ability.range
	local d = self.entity:get_distance(entitydata.entity)
	local withinrange = (d <= range)
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

	if self.entity ~= nil then
		if self.entity.ishero then
			self.entity:set_animation(anim)
		else
			self.entity.main_sprite:set_animation(anim)
			self.entity.main_sprite:set_paused(false)
		end
	end
end

function EntityData:getanimation(entity)
	if entity == nil then entity = self.entity end
	if entity.ishero then
		return entity:get_animation()
	else
		return entity.main_sprite:get_animation()
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
	if target.entity == nil then return end

	if target.receivedamage ~= nil then
		local returnvalue = target:receivedamage(self, damage, aspects)
		if returnvalue then
			return
		end
	end

	local map = self.entity:get_map()

	if aspects == nil then
		aspects = {}
	end

	if aspects.natural then
		aspects.sameteam = true
	end

	if not self:cantarget(target, aspects.sameteam, nil, aspects.onlyonsameteam) then
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
		aspects.knockback = 200
	end
	if aspects.fromentity == nil then
		aspects.fromentity = self.entity
	end

	if aspects.electric ~= nil then
--		aspects.knockback = 0

--		stuneffect = Effects.StunEffect(target, aspects.stun)
--		electriceffect = Effects.ElectricalEffect(target, aspects.stun)
--		if target:getfrozen() == nil then
			local electricstuneffect = Effects.ElectricalStunEffect(target, aspects.electric)
--		end
	end
	if aspects.stun ~= nil then
--		aspects.knockback = 0

--		stuneffect = Effects.StunEffect(target, aspects.stun)
--		electriceffect = Effects.ElectricalEffect(target, aspects.stun)
--		if target:getfrozen() == nil then
			local stun = Effects.StunEffect(target, aspects.stun)
--		end
	end
	if aspects.fire ~= nil then
		local fireeffect = Effects.FireEffect(target, aspects.fire)
	end
	if aspects.poison ~= nil then
		local poisoneffect = Effects.PoisonWeaknessEffect(target, aspects.poison.weakness, aspects.poison.time)
	end
	if aspects.haste ~= nil then
		local hasteeffect = Effects.HasteEffect(target)
	end
	if aspects.slow ~= nil then
		local sloweffect = Effects.SlowEffect(target, aspects.slow.sprite)
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

	if not aspects.natural then
		local souls = self.souls
		local damagemultiplier = souls
		if self.entity.ishero then
			damagemultiplier = damagemultiplier + 0.5
		end
		damage = damage * damagemultiplier
	end

	if aspects.ap == nil then
		local negateddamage = damage * target.stats.defense
		damage = damage - negateddamage
	end

	target.life = target.life - damage

	local x, y = target.entity:get_position()
	map:damagedisplay(damage, x, y)

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
			local angle = nil
			if aspects.knockbackrandomangle then
				angle = math.random() * 2 * math.pi
			end
			if aspects.directionalknockback then
				angle = aspects.fromentity:get_direction() * math.pi / 2
			end
			if aspects.knockbackangle ~= nil then
				angle = aspects.knockbackangle
			end
			local kbe = Effects.KnockBackEffect:new(target, aspects.fromentity, aspects.knockback, angle)
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

	if target.life <= 0 or aspects.instantdeath or (game.instantdeath and damage ~= 0) then
		local remainingmonsters = self:getremainingmonsters()
		if self.team ~= "adventurer" then
			remainingmonsters = remainingmonsters - 1
		end

		target:kill()

		if remainingmonsters == 0 then
			map.nomonstersleft = true
		end
	else
		if target.stages ~= nil then
			for stagelife, stagefunct in pairs(target.stages) do
				if target.life/target.maxlife < stagelife then
					print("target", target.theclass, "entered new stage", stagelife)
					stagefunct()
					if self.usingability ~= nil then
						self.usingability:cancel()
					end
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

	local game = self.entity:get_game()
	if game.nodeaths then
		return
	end

	local theishero = self.entity.ishero

	local x,y,layer = self.entity:get_position()
	sol.audio.play_sound("enemy_killed")

	local map = self.entity:get_map()
	map:create_custom_entity({
		model="death",
		layer=2,
		x=x,
		y=y,
		direction=0
	})

	if self.usingability then
		self.usingability:cancel()
	end

	if self.entity ~= nil then
		self.entity.entitydata = nil

		if self:getremainingadventurers(true) <= 0 then
			self:swordkill()
		end
	end

	for key, effect in pairs(self.effects) do
		effect:forceremove()
	end

	if theishero then
		-- drop sword
		self:drop()

--		local newentity = self:unpossess()
--		newentity.entitydata:kill()
	else
--		self:freeze()
		local freezeeffect = Effects.FreezeEffect:new(self)
--		self.entity:set_life(0)
		self.entity:remove()
	end

	self.entity = nil
end

function EntityData:dropsword()
	local hero = self.entity

	if not hero.ishero then return end
	if hero.isthrown then return end
	if hero.isdropped then return end

	self:dodamage(self, 0, {sameteam=true}) -- cancel ability

	self:drop()

	local newentity = self:unpossess()

	for key, effect in pairs(self.effects) do
		effect:forceremove()
	end
end

function EntityData:swordkill()
	-- sword health runs out

	local game = self.entity:get_game()
	if game.nodeaths then
		return
	end
	local hero = game:get_hero()

	print("HERO DEATH!")

	for key, effect in pairs(self.effects) do
		effect:forceremove()
	end

	hero.swordhealth = hero.maxswordhealth

--	-- TODO: make this work
--	self.entity:teleport(self.entity:get_map():get_id())
	game.hasended = true
end

function EntityData:drop(hero, notimer)
	-- sword is dropped on the ground if person holding demon sword is killed

	if hero == nil then hero = self.entity end
	if hero.ishero then
		hero.entitydata = nil
		hero:set_animation("stopped")
		hero:set_tunic_sprite_id("abilities/droppedsword")
		hero:freeze()
		hero.isdropped = true

		if not notimer then
			Effects.SimpleTimer(hero:get_game(), 10000, function() self:emergencyrescuehero(hero) end)
		end
	else
		print("ERROR: drop called not on hero")
	end
end

function EntityData:emergencyrescuehero(hero)
	if hero.isdropped then
		for entity in hero:get_map():get_entities("") do
			if entity.entitydata ~= nil then
				local entitydata = entity.entitydata
				if entitydata.team == "adventurer" then
					local x, y = hero:get_position()
					entity:set_position(x,y)
					return
				end
			end
		end
	end
end

function EntityData:throwsword(entitydata2)
	-- throws the demon sword to another person

--	self:log("going to throw to", entitydata2.class)
	local hero = self.entity

	if self.entity.ishero then
--		if self.usingability ~= nil and not self.usingability.usingwarmup then
--			return
--		end

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

		if self.usingability and self.usingability.usingwarmup then
			local x, y = self.usingability:gettargetpos()
			local direction = self.entity:get_direction4_to(x, y)
			self:setdirection(direction)
		end

		sol.audio.play_sound("swing" .. math.random(1,3))

		hero.isthrown = true

		local newentity = self:unpossess()

		hero:freeze()

		hero:set_tunic_sprite_id("abilities/thrownsword")
		hero:set_animation("stopped")

		hero:stop_movement()

		if game.fastthrow then
			entitydata2:bepossessedbyhero()
		else
			local movement = sol.movement.create("target")
			movement:set_speed(1000)
			movement:set_target(entitydata2.entity)
			movement:start(hero)

			local floor = hero:get_map():get_floor()

	--[[
			function movement:on_obstacle_reached()
				movement:stop()
				EntityData:drop(hero)
			end
	--]]
			function movement:on_finished()
				entitydata2:bepossessedbyhero()
			end

			function movement:on_position_changed()
				if entitydata2.entity == nil then
					self:stop()
					EntityData:drop(hero)
				else
					local d = hero:get_distance(entitydata2.entity)
					if d < 30 then
						self:stop()
						entitydata2:bepossessedbyhero()
					end
				end
			end

			if floor == 1 then
				function movement.on_obstacle_reached(movement, dx, dy)
					local x, y = hero:get_position()
					hero:set_position(x+dx, y+dy)
					for entity in hero:get_map():get_entities("") do
						if entity:get_type() == "wall" then
							local name = entity:get_name()
							if name == nil or not string.find(name, "sword") then
								if hero:overlaps(entity) then
									-- drop sword
									movement:stop()
									hero.isthrown = false
									self:drop(hero)
								end
							end
						end
					end
					hero:set_position(x, y)
				end
				movement:set_ignore_obstacles()
				movementaccuracy.targetstopper(movement, hero, entitydata2.entity)
			else
				movement:set_ignore_obstacles()
			end
		end
	end
end

function EntityData:getrandom()
	-- get random person on map
	-- does not include self

--	local map = game:get_map()
--	local hero = game:get_hero()

	local entitieslist = {}
	for entitydata in self:getotherentities() do
		local entity = entitydata.entity
		entitieslist[#entitieslist+1] = entity
	end

	local entity = entitieslist[math.random(#entitieslist)]
	return entity
end

function EntityData:throwrandom()
	-- throw sword to random person
	local entity = self:getrandom()

	local hero = self.entity

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

	local angle = self.entity:get_angle(x, y)

	local minangle = 999
	local minentity = nil

--	local map = game:get_map()
--	local hero = self.entity

	for entitydata in self:getotherentities() do
		local entity = entitydata.entity
		local angle2 = self.entity:get_angle(entity)
		local d = math.abs(angle - angle2)
		if d < minangle then
			minangle = d
			minentity = entity.entitydata
		end
	end

	return minentity
end

function EntityData:getclosestentity(x, y, isenemy, funct, isself)
	-- find person closest to a point
	-- does not include self
	-- can be used to find person closest to mouse pointer (used with gettargetpos)

	local mindist = 99999
	local minentity = nil

--	local map = game:get_map()
--	local hero = self.entity

	for entitydata in self:getotherentities() do
		if not isenemy or self:cantarget(entitydata) then
			if (funct == nil) or (funct(entitydata) == true) then
				local entity = entitydata.entity
				local d = entity:get_distance(x, y)
				if d < mindist then
					mindist = d
					minentity = entity.entitydata
				end
			end
		end
	end
	
	if isself then
		local entitydata = self
		if not isenemy or self:cantarget(entitydata) then
			if (funct == nil) or (funct(entitydata) == true) then
				local entity = entitydata.entity
				local d = entity:get_distance(x, y)
				if d < mindist then
					mindist = d
					minentity = entity.entitydata
				end
			end
		end
	end

	return minentity
end

function EntityData:throwclosest(isally)
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

	local x, y = self:gettargetpos()
	local entity = self:getclosestentity(x, y, false,
		function(entitydata)
			if entitydata.cantpossess then
				return false
			end
			if isally == true and entitydata.team ~= "adventurer" then
				return false
			end
			if isally == false and entitydata.team == "adventurer" then
				return false
			end
			return true
		end)
	local hero = self.entity
	if entity ~= nil then
		if hero.entitydata ~= nil then
			hero.entitydata:throwsword(entity)
		end
	end
end

function EntityData:gettargetpos()
	-- returns the mouse pointer position if hero
	-- returns AI aiming position if AI

	if self.manualtarget ~= nil then
		local x, y = self.manualtarget:get_position()
		return x, y
	end

	if self.entity.ishero then
		local map = self.entity:get_map()
		local mousex, mousey = sol.input.get_mouse_position()
		local cx, cy, cw, ch = map:get_camera_position()
		local x, y = mousex + cx, mousey + cy
		if x == nil then
			print("Unable to get mouse position!")
			x, y = 0, 0
		end
		return x, y
--		return self.entity.targetx, self.entity.targety
	else
		local target = self.entity.lasttarget
		if target.entity == nil then target = self.entity:targetenemy() end
		if target ~= nil then
			local x, y
			if self.usingability ~= nil and self.usingability.abilitytype == "block" then
				x, y = self.entity:getblockposition(target)
			elseif self.usingability ~= nil and self.usingability.heals then
				x, y = self.entity:get_position()
				target = self:getclosestentity(x,y,nil,function(entitydata) return entitydata.team == self.team end)
				x, y = target.entity:get_position()
			else
				x, y = target.entity:get_position()
			end
			if x == nil then
				x, y = 0, 0
			end
			return x, y
		end
		return 0, 0
	end
end

function EntityData:isonscreen(border)
	if border == nil then border = 0 end

	local x, y = self.entity:get_position()
	local map = self.entity:get_map()
	local cx, cy, cw, ch = map:get_camera_position()
	local cl, cb = cx+cw, cy+ch

	return (x >= cx-border and y >= cy-border and x <= cl+border and y <= cb+border)
end

function EntityData:getremainingmonsters()
	local enemiesremaining = 0

	if self.team == "monster" then
		enemiesremaining = 1
	end

	for entitydata in self:getotherentities() do
		if entitydata.team == "monster" and not entitydata.doesntcountsasmonster then
			enemiesremaining = enemiesremaining + 1
		end
	end

	return enemiesremaining
end

function EntityData:getremainingadventurers(dontcountself)
	local enemiesremaining = 0

	if not dontcountself then
		if self.team == "adventurer" and self.entity ~= nil then
			enemiesremaining = 1
		end
	end

	for entitydata in self:getotherentities() do
		if entitydata.team == "adventurer" and not entitydata.doesntcountsasadventurer then
			enemiesremaining = enemiesremaining + 1
		end
	end

	return enemiesremaining
end

function EntityData:canmoveto(tox, toy)
	local entity = self.entity

	return movementaccuracy.canmoveto(entity, tox, toy)
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
		specialability = self.specialability.name,
		ispuzzle=(self.entity:get_map():get_floor() == 1)
	}
end

function EntityData:changemovements(oldentity, newentity)
	for entity, movement in pairs(_movements) do
		if movement.target == oldentity then
			movement:set_target(newentity)
		end
	end
end

-- Actual classes

local allclasses = {EntityData=EntityData}

function EntityData.static:fromtable(table, entity)
	local theclass
	for _, class in pairs(allclasses) do
		if class.name == table.classname then
			theclass = class
			break
		end
	end
	if theclass ~= nil then
		local entitydata = theclass:new(entity)
		entitydata.entity = entity
		entitydata:applytoentity()

		if not table.ispuzzle then
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
		end

		entitydata.life = table.life
		entitydata.maxlife = table.maxlife
		entitydata.team = table.team

		return entitydata
	end
end


-- Test classes:

local yellowclass = EntityData:subclass("yellowclass")
allclasses.yellowclass = yellowclass

function yellowclass:initialize(entity)
	local class = "yellow"
	local main_sprite = "adventurers/guy2"
	local life = 10
	local team = "yellow" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {FireballAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "holy")}
	local blockabilities = {TeleportAbility:new(self)}
	local specialabilities = {StealthAbility:new(self)}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local greenclass = EntityData:subclass("greenclass")
allclasses.greenclass = greenclass

function greenclass:initialize(entity)
	local class = "green"
	local main_sprite = "adventurers/guy3"
	local life = 10
	local team = "green" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {HealAbility:new(self), FireballAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "poison")}
	local blockabilities = {ShieldAbility:new(self)}
	local specialabilities = {BombThrowAbility:new(self), GrapplingHookAbility:new(self)}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local debuggerclass = EntityData:subclass("debuggerclass")
allclasses.debuggerclass = debuggerclass

function debuggerclass:initialize(entity)
	local class = "debugger"
	local main_sprite = "adventurers/knight"
	local life = 10
	local team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	local allabilities = {
		[AngelSummonAbility(self)]="adventurers/cleric",
		[BackstabAbility(self)]="adventurers/rogue",
		[BlackholeAbility(self)]="adventurers/mage",
		[BodyDoubleAbility(self)]="adventurers/rogue",
		[BoulderAbility(self)]="bosses/dunsmur-1",
		[CatKickAbility(self, "kick")]="bosses/cat-1",
		[CatShootAbility(self, "fast")]="bosses/cat-1",
		[CatKickAbility(self, "downkick")]="bosses/cat-2",
		[CatShootAbility(self, "power")]="bosses/cat-2",
		[CatKickAbility(self, "spin")]="bosses/cat-3",
		[CatKickAbility(self, "uppercut")]="bosses/cat-3",
		[ChargeAbility(self)]="adventurers/knight",
		[EarthquakeAbility(self)]="adventurers/mage",
		[FireballAbility(self)]="adventurers/mage",
		[FireballConeAbility(self)]="bosses/dunsmur-1",
		[FiringBowAbility(self)]="adventurers/archer",
		[GrapplingHookAbility(self)]="adventurers/archer",
		[GunAbility(self)]="monsters/mech",
		[HealAbility(self)]="adventurers/cleric",
		[HealExplosionAbility(self)]="adventurers/cleric",
		[LightningAbility(self)]="adventurers/mage",
		[NormalAbility(self)]="monsters/spiders/spider01",
		[PossessAbility(self)]="bosses/dunsmur-1",
		[ShieldAbility(self)]="adventurers/knight",
		[ShieldBashAbility(self)]="adventurers/knight",
		[SidestepAbility(self)]="adventurers/rogue",
		[SpaceShipProjectileAbility(self)]="bosses/spaceship-1",
		[SpaceShipProjectile2Ability(self)]="bosses/spaceship-1",
		[SpaceShipProjectile3Ability(self)]="bosses/spaceship-1",
		[SpaceShipProjectile4Ability(self)]="bosses/spaceship-1",
		[SpaceShipProjectile5Ability(self)]="bosses/spaceship-1",
		[SpaceShipProjectile6Ability(self)]="bosses/spaceship-1",
		[StealthAbility(self)]="adventurers/rogue",
		[StompAbility(self)]="adventurers/berserker",
		[SwordAbility(self)]="adventurers/knight",
		[TauntAbility(self)]="adventurers/bard",
		[TeleportAbility(self)]="adventurers/mage",
		[TentacleAbility(self)]="bosses/mage-1",
		[BombThrowAbility(self)]="adventurers/archer",
		[TrapsAbility(self)]="adventurers/rogue"
	}
	local normalabilities = {}
	for ability, sprite in pairs(allabilities) do
		normalabilities[#normalabilities+1] = ability
	end
	table.sort(normalabilities, function(a,b) return a.name < b.name end)
	self.allabilities = allabilities
	local transformabilities = {TransformAbility(self, "ap"),
		TransformAbility(self, "electric"),
		TransformAbility(self, "fire"),
		TransformAbility(self, "poison"),
		TransformAbility(self, "damage"),
		TransformAbility(self, "lifesteal"),
		TransformAbility(self, "holy"),
		TransformAbility(self, "dagger")
	}
	local blockabilities = {NothingAbility(self)}
	local specialabilities = {NothingAbility(self)}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
	self:onabilitychanged()
end

function debuggerclass:onabilitychanged()
	local ability = self.swordability
	local num
	for index, normalability in pairs(self.normalabilities) do
		if normalability == ability then
			num = index
			break
		end
	end
	print("Number:", num)
	local sprite = self.allabilities[ability]
	self.main_sprite = sprite
	self:applytoentity()
end

-- Adventurers:

local knightclass = EntityData:subclass("knightclass")
allclasses.knightclass = knightclass

function knightclass:initialize(entity)
	local class = "knight"
	local main_sprite = "adventurers/knight"
	local life = 10
	local team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SwordAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "ap")}
	local blockabilities = {ShieldAbility:new(self)}
	local specialabilities = {ChargeAbility:new(self), ShieldBashAbility:new(self)}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local mageclass = EntityData:subclass("mageclass")
allclasses.mageclass = mageclass

function mageclass:initialize(entity)
	local class = "mage"
	local main_sprite = "adventurers/mage"
	local life = 10
	local team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SwordAbility:new(self), FireballAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "electric"), TransformAbility:new(self, "fire")}
	local blockabilities = {TeleportAbility:new(self)}
	local specialabilities = {LightningAbility:new(self), EarthquakeAbility:new(self), BlackholeAbility:new(self)}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local clericclass = EntityData:subclass("clericclass")
allclasses.clericclass = clericclass

function clericclass:initialize(entity)
	local class = "cleric"
	local main_sprite = "adventurers/cleric"
	local life = 10
	local team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SwordAbility:new(self), HealAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "holy"), TransformAbility:new(self, "lifesteal")}
	local blockabilities = {SidestepAbility:new(self)}
	local specialabilities = {AngelSummonAbility:new(self), HealExplosionAbility:new(self)}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local rogueclass = EntityData:subclass("rogueclass")
allclasses.rogueclass = rogueclass

function rogueclass:initialize(entity)
	local class = "rogue"
	local main_sprite = "adventurers/rogue"
	local life = 10
	local team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SwordAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "dagger"), TransformAbility:new(self, "poison")}
	local blockabilities = {SidestepAbility:new(self), BodyDoubleAbility:new(self)}
	local specialabilities = {TrapsAbility:new(self), BackstabAbility:new(self), StealthAbility:new(self)}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local bardclass = EntityData:subclass("bardclass")
allclasses.bardclass = bardclass

function bardclass:initialize(entity)
	local class = "bard"
	local main_sprite = "adventurers/bard"
	local life = 10
	local team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SwordAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "slow")}
	local blockabilities = {SidestepAbility:new(self)}
	local specialabilities = {TauntAbility:new(self), HasteAbility:new(self), DefenseAbility:new(self)}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local berserkerclass = EntityData:subclass("berserkerclass")
allclasses.berserkerclass = berserkerclass

function berserkerclass:initialize(entity)
	local class = "berserker"
	local main_sprite = "adventurers/berserker"
	local life = 10
	local team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SwordAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "damage")}
	local blockabilities = {ShieldAbility:new(self)}
	local specialabilities = {StompAbility:new(self), RageAbility:new(self)}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local archerclass = EntityData:subclass("archerclass")
allclasses.archerclass = archerclass

function archerclass:initialize(entity)
	local class = "archer"
	local main_sprite = "adventurers/archer"
	local life = 10
	local team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {BoomerangAbility:new(self), FiringBowAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "dagger")}
	local blockabilities = {SidestepAbility:new(self)}
	local specialabilities = {GrapplingHookAbility:new(self), BombThrowAbility:new(self), NetAbility:new(self, "net")}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

-- Monsters:

local skeletonclass = EntityData:subclass("skeletonclass")
allclasses.skeletonclass = skeletonclass

function skeletonclass:initialize(entity)
	local class = "skeleton"
	local main_sprite = "monsters/skeleton"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {FiringBowAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "ap"), TransformAbility:new(self, "damage")}
	local blockabilities = {ShieldAbility:new(self)}
	local specialabilities = {ShieldBashAbility:new(self), GrapplingHookAbility:new(self)}
	local basestats = {}
	self.undead = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local orcclass = EntityData:subclass("orcclass")
allclasses.orcclass = orcclass

function orcclass:initialize(entity)
	local class = "orc"
	local main_sprite = "monsters/orc"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SwordAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "ap"), TransformAbility:new(self, "damage")}
	local blockabilities = {ShieldAbility:new(self)}
	local specialabilities = {ShieldBashAbility:new(self), BombThrowAbility:new(self)}
	local basestats = {damage=2, warmup=1.5}
	self.cantdraweyes = true
	self.undead = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local evilmageclass = EntityData:subclass("evilmageclass")
allclasses.evilmageclass = evilmageclass

function evilmageclass:initialize(entity)
	local class = "evil mage"
	local main_sprite = "monsters/evilmage"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {FireballAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "electric"), TransformAbility:new(self, "fire"), TransformAbility:new(self, "poison")}
	local blockabilities = {TeleportAbility:new(self)}
	local specialabilities = {LightningAbility:new(self), EarthquakeAbility:new(self), BlackholeAbility:new(self)}
	local basestats = {}
	self.undead = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local spiderclass = EntityData:subclass("spiderclass")
allclasses.spiderclass = spiderclass

function spiderclass:initialize(entity)
	local class = "spider"
	local main_sprite = "monsters/spiders/spider" .. string.format("%02d", math.random(1,11))
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local aspects = {poison = {weakness=0.4, time=5000}}
	local normalabilities = {NormalAbility:new(self, "sword", aspects)}
	local transformabilities = {TransformAbility:new(self, "poison")}
	local blockabilities = {SidestepAbility:new(self)}
	local specialabilities = {NetAbility:new(self, "spiderweb")}
	local basestats = {}
	self.cantdraweyes = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local mechclass = EntityData:subclass("mechclass")
allclasses.mechclass = mechclass

function mechclass:initialize(entity)
	local class = "mech"
	local main_sprite = "monsters/mech"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {GunAbility:new(self)}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {NothingAbility:new(self)}
	local specialabilities = {NothingAbility:new(self)}
	local basestats = {}
	self.cantdraweyes = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local beetleclass = EntityData:subclass("beetleclass")
allclasses.beetleclass = beetleclass

function beetleclass:initialize(entity)
	local class = "beetle"
	local main_sprite = "monsters/beetle"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {NormalAbility:new(self)}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {SidestepAbility:new(self)}
	local specialabilities = {NothingAbility:new(self)}
	local basestats = {}
	self.cantdraweyes = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local ghostclass = EntityData:subclass("ghostclass")
allclasses.ghostclass = ghostclass

function ghostclass:initialize(entity)
	local class = "ghost"
	local main_sprite = "monsters/ghost"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {FireballAbility:new(self)}
	local transformabilities = {SwordAbility:new(self, "fire")}
	local blockabilities = {TeleportAbility:new(self)}
	local specialabilities = {StealthAbility:new(self)}
	local basestats = {movementspeed=100}
	self.cantdraweyes = true
	self.undead = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local flowerclass = EntityData:subclass("flowerclass")
allclasses.flowerclass = flowerclass

function flowerclass:initialize(entity)
	local class = "flower"
	local main_sprite = "monsters/flower"
	local life = 20
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SeedShootAbility:new(self)}
	local transformabilities = {SwordAbility:new(self, "fire")}
	local blockabilities = {NothingAbility:new(self)}
	local specialabilities = {GrapplingHookAbility:new(self, "vine")}
	local basestats = {movementspeed=0}
	self.cantdraweyes = true
	self.cantcancel = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local batclass = EntityData:subclass("batclass")
allclasses.batclass = batclass

function batclass:initialize(entity)
	local class = "bat"
	local main_sprite = "monsters/bat"
	local life = 5
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {NormalAbility:new(self, "casting", {lifesteal=true}), HealAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "lifesteal")}
	local blockabilities = {SidestepAbility:new(self)}
	local specialabilities = {HealExplosionAbility:new(self)}
	local basestats = {movementspeed=200, damage=0.8}
	self.cantdraweyes = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local beeclass = EntityData:subclass("beeclass")
allclasses.beeclass = beeclass

function beeclass:initialize(entity)
	local class = "bee"
	local main_sprite = "monsters/bee"
	local life = 5
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {NormalAbility:new(self, "casting")}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {SidestepAbility:new(self)}
	local specialabilities = {BackstabAbility:new(self)}
	local basestats = {movementspeed=200, damage=0.8}
	self.cantdraweyes = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local wormclass = EntityData:subclass("wormclass")
allclasses.wormclass = wormclass

function wormclass:initialize(entity)
	local class = "worm"
	local main_sprite = "monsters/big_worm"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {NormalAbility:new(self, "casting")}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {NothingAbility:new(self)}
	local specialabilities = {NothingAbility:new(self)}
	local basestats = {damage=2}
	self.cantdraweyes = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local slimeclass = EntityData:subclass("slimeclass")
allclasses.slimeclass = slimeclass

function slimeclass:initialize(entity)
	local class = "slime"
	local main_sprite = "monsters/slime"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {NormalAbility:new(self, "casting")}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {NothingAbility:new(self)}
	local specialabilities = {NothingAbility:new(self)}
	local basestats = {damage=0.5}
	self.cantdraweyes = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local eyeclass = EntityData:subclass("eyeclass")
allclasses.eyeclass = eyeclass

function eyeclass:initialize(entity)
	local class = "floating eyeball"
	local main_sprite = "monsters/eyeball"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {FireballAbility:new(self, "casting")}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {TeleportAbility:new(self)}
	local specialabilities = {LightningBallAbility:new(self)}
	local basestats = {warmup=0.5, cooldown=0.5}
	self.cantdraweyes = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local maskmanclass = EntityData:subclass("maskmanclass")
allclasses.maskmanclass = maskmanclass

function maskmanclass:initialize(entity)
	local class = "mask man"
	local main_sprite = "monsters/maskman"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {NormalAbility:new(self, "casting")}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {TeleportAbility:new(self), ShieldAbility:new(self)}
	local specialabilities = {StompAbility:new(self)}
	local basestats = {}
	self.cantdraweyes = true
	self.undead = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local wolfclass = EntityData:subclass("wolfclass")
allclasses.wolfclass = wolfclass

function wolfclass:initialize(entity)
	local class = "wolf"
	local main_sprite = "monsters/wolf"
	local life = 10
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {NormalAbility:new(self, "sword")}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {NothingAbility:new(self)}
	local specialabilities = {HasteAbility:new(self), DefenseAbility:new(self)}
	local basestats = {}
	self.cantdraweyes = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

-- Bosses

local spaceshipboss = EntityData:subclass("spaceshipboss")
allclasses.spaceshipboss = spaceshipboss

function spaceshipboss:initialize(entity)
	local class = "Space Ship (Boss)"
	local main_sprite = "bosses/spaceship-1"
	local life = 200
	local team = "boss" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SpaceShipProjectileAbility:new(self)}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {NothingAbility:new(self)}
	local specialabilities = {SpaceShipProjectile2Ability:new(self)}
	local basestats = {}
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

local mageboss = EntityData:subclass("mageboss")
allclasses.mageboss = mageboss

function mageboss:initialize(entity)
	local class = "Mage (Boss)"
	local main_sprite = "bosses/mage-1"
	local life = 200
	local team = "boss" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {NothingAbility:new(self)}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {NothingAbility:new(self)}
	local specialabilities = {TentacleAbility:new(self)}
	local basestats = {movementspeed=0}
	self.cantpossess=true
	self.cantcancel = true
	self.alwaysrandom = true

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


local catboss = EntityData:subclass("catboss")
allclasses.catboss = catboss

function catboss:initialize(entity)
	local class = "Cat (Boss)"
	local main_sprite = "bosses/cat-1"
	local life = 200
	local team = "boss" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {CatKickAbility:new(self, "kick")}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {SidestepAbility:new(self)}
	local specialabilities = {CatShootAbility:new(self, "fast")}
	local basestats = {movementspeed=150}
	self.cantdraweyes = true
	self.cantpossess = true

	self.stages = {[0.66] = function() self:stage2() end, [0.33] = function() self:stage3() end}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

function catboss:getdirection()
	local d = EntityData.getdirection(self)
	if d == 1 then d = 0 end
	if d == 3 then d = 2 end
	return d
end

function catboss:stage2()
	self.main_sprite = "bosses/cat-2"
	self.swordability = CatKickAbility:new(self, "downkick")
	self.specialability = CatShootAbility:new(self, "power")
end

function catboss:stage3()
	self.main_sprite = "bosses/cat-3"
	self.swordability = CatKickAbility:new(self, "spin")
	self.specialability = CatKickAbility:new(self, "uppercut")
end


local dunsmurclass = EntityData:subclass("dunsmurclass")
allclasses.dunsmurclass = dunsmurclass

function dunsmurclass:initialize(entity)
	local class = "Duns Mur"
	local main_sprite = "bosses/dunsmur-1"
	local life = 300
	local team = "dunsmur" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SwordAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "lifesteal")}
	local blockabilities = {ShieldAbility:new(self)}
	local specialabilities = {PossessAbility:new(self)}
	local basestats = {}
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

local angelclass = EntityData:subclass("angelclass")
allclasses.angelclass = angelclass

function angelclass:initialize(entity)
	local class = "angel"
	local main_sprite = "adventurers/angel"
	local life = 5
	local team = "adventurer" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {SwordAbility:new(self)}
	local transformabilities = {TransformAbility:new(self, "holy")}
	local blockabilities = {ShieldAbility:new(self)}
	local specialabilities = {HealExplosionAbility:new(self)}
	local basestats = {}

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local dummyclass = EntityData:subclass("dummyclass")
allclasses.dummyclass = dummyclass

function dummyclass:initialize(entity)
	local class = "baddummyclass"
	local main_sprite = "adventurers/dummy"
	local life = 5
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {NothingAbility:new(self)}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {NothingAbility:new(self)}
	local specialabilities = {NothingAbility:new(self)}
	local basestats = {movementspeed=0}
	self.dontmove = true
	self.doesntcountsasadventurer = true
	self.cantpossess = true
	self.cantdraweyes = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

local lever = EntityData:subclass("lever")

allclasses.lever = lever
function lever:initialize(entity)
	local class = "lever"
	local main_sprite = "Traps/lever"
	local life = 5
	local team = "monster" -- should be either "adventurer" or "monster" in the final version
	local normalabilities = {NothingAbility:new(self)}
	local transformabilities = {NothingAbility:new(self)}
	local blockabilities = {NothingAbility:new(self)}
	local specialabilities = {NothingAbility:new(self)}
	local basestats = {movementspeed=0}
	self.dontmove = true
	self.doesntcountsasmonster = true
	self.cantpossess = true
	self.time = 5000
	self.dontdrawlifebar = true

	self.normalabilities, self.transformabilities, self.blockabilities, self.specialabilities = normalabilities, transformabilities, blockabilities, specialabilities
	EntityData.initialize(self, entity, class, main_sprite, life, team, normalabilities, transformabilities, blockabilities, specialabilities, basestats)
end

function lever:isvisible()
	return false
end

function lever:receivedamage(fromentitydata, damage, aspects)
	if damage > 0 then
		self:setanimation("pulled")
--		local door = self:getdoor()
		for door in self.entity:get_map():get_entities("") do
			if door.isdoor then
				local name = self:getname()
				if door:get_name():match(".*" .. name .. ".*") then
					sol.audio.play_sound("dooropen")
					door:open(self)
					sol.audio.play_sound("clock")
					self.timer = Effects.SimpleTimer(self, self.time, function()
						self:setanimation("stopped")
						sol.audio.play_sound("doorclose")
						door:close(self)
					end)
				end
			end
		end
	end
	return true
end

function lever:getname()
	local myname = self.entity:get_name()
	local startname, _, endname = myname:match("([^_]+)_([^_]+)") -- split by _
	return startname
end

_EntityDatas = allclasses

return allclasses

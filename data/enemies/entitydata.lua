local class = require "middleclass"

EntityData = class("EntityData")

SwordAbility = require "abilities/sword"
TransformAbility = require "abilities/swordtransform"
ShieldAbility = require "abilities/shield"
ChargeAbility = require "abilities/charge"
ShieldBashAbility = require "abilities/shieldbash"
BombThrowAbility = require "abilities/throwbomb"
GrapplingHookAbility = require "abilities/grapplinghook"
LightningAbility = require "abilities/lightning"
FireballAbility = require "abilities/fireball"

Effects = require "enemies/effect"

function EntityData:log(...)
	colstart = ""
	colend = ""
	if self.getlogcolor ~= nil then
		colstart = string.char(27) .. '[' .. self:getlogcolor() .. 'm'
		colend = string.char(27) .. '[' .. "0" .. 'm'
	end

	print(colstart .. self.class, ...)
	io.write(colend)
end

local maxhealth

function EntityData:initialize(entity, class, main_sprite, life, team, swordability, transformability, blockability, specialability, stats)
	self.entity = entity
	self.class = class
	self.main_sprite = main_sprite
	self.life = life
	self.maxlife = self.life
	self.team = team
	self.swordability = swordability
	self.transformability = transformability
	self.blockability = blockability
	self.specialability = specialability
	self.effects = {}
	self.positionlisteners = {}

	if stats.damage == nil then
		stats.damage = 1
	end
	if stats.defense == nil then
		stats.defense = 0.3
	end
	if stats.movementspeed == nil then
		stats.movementspeed = 64
	end
	if stats.warmup == nil then
		stats.warmup = 1
	end
	if stats.cooldown == nil then
		stats.cooldown = 1
	end

	self.originalstats = stats
	self.stats = stats

	self:log("initialized")
end

function EntityData:get_max_health()
	return self.maxhealth
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

	if self.entity.ishero then
		self.entity:set_tunic_sprite_id(self.main_sprite)
	else
		self.entity:load_entitydata()
	end

	self:updatemovementspeed()

	function self.entity:on_position_changed(x, y, layer)
		if self.entitydata ~= nil then
			for index, value in pairs(self.entitydata.positionlisteners) do
				if value ~= nil then
					value(x, y, layer)
				end
			end
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

	self:log("sword has possessed")
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

	self:log("sword has left")

	return self.entity
end

function EntityData:cantarget(entitydata)
	if entitydata == nil then
--		self:log("can't target", entitydata, "because entitydata nil")
		return false
	end

	if entitydata == self then
--		self:log("can't target", entitydata, "because self-targeting")
		return false
	end

	if not entitydata:isvisible() then
--		self:log("can't target", entitydata, "because invisible")
		return false
	end

	if entitydata.team == self.team then
--		self:log("can't target", entitydata, "because same team")
		return false
	end

	return true
end

function EntityData:cantargetentity(entity)
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
	return true
end

function EntityData:getotherentities()
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
	if self.usingability == nil then
		actualability = self:getability(ability)
		if actualability.canuse then
			actualability.abilitytype = ability
			self:log("ABILITY", ability, actualability)
			actualability:start(...)
			return actualability
		end
	end
end

function EntityData:endability(ability, ...)
	if self.usingability ~= nil then
		if self.usingability == self:getability(ability) then
			self.usingability:finish(...)
		end
	end
end

function EntityData:tickability(...)
	if self.usingability ~= nil then
		self.usingability:tick(...)
	end
end

function EntityData:canuseability(ability)
	actualability = self:getability(ability)
	return actualability.canuse
end

function EntityData:withinrange(ability, entitydata)
	-- if an entity can be attacked using the ability
	ability = self:getability(ability)
	range = ability.range
	d = self.entity:get_distance(entitydata.entity)
	withinrange = (d <= range)
	return withinrange
end

function EntityData:getdirection()
	if self.entity.ishero then
		return self.entity:get_direction()
	else
		return self.entity.direction
	end
end

function EntityData:setanimation(anim)
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
	if not self:cantarget(target) and aspects.natural == nil then
		self:log("Can't target!")
		return
	end

	if target.usingability ~= nil and not aspects.dontblock then
		damage, aspects = target.usingability:blockdamage(self, damage, aspects)
	end

	if aspects.donothing then
		return
	end
	--reverse cancel
	if aspects.reversecancel ~= nil then
		target:dodamage(self, 0, {knockback=0, stun=aspects.reversecancel, dontblock=true})
		return
	end


	--cancel enemy's ability
	if aspects.natural == nil and aspects.dontcancel == nil then
		if target.usingability ~= nil then
			target.usingability:cancel()
		end
	end

	-- aspects
	if aspects.knockback == nil then
		aspects.knockback = 500
	end
	if aspects.fromentity == nil then
		aspects.fromentity = self.entity
	end

	if aspects == nil then
		aspects = {}
		self:log("reset aspects")
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
		self:log("catch on fire", knockback)
		fireeffect = Effects.FireEffect(target, aspects.fire)
	end
	if aspects.poison ~= nil then
		poisoneffect = Effects.PoisonWeaknessEffect(target, aspects.poison.weakness, aspects.poison.time)
	end
	if aspects.flame ~= nil then
		self:log("fire damage")
		aspects.knockback = 0
	end
	if aspects.method ~= nil then
		aspects.method()
	end

	-- do damage
	damage = damage * self.stats.damage
	if aspects.ap == nil then
		negateddamage = damage * target.stats.defense
		damage = damage - negateddamage
	end

	target.life = target.life - damage
	target:log("damaged", damage, "life", target.life)

	--aggro
	if not target.entity.ishero and target ~= self then
		target.entity.entitytoattack = self
	end

	--knockback
	if aspects.knockback ~= 0 then
		target:log("knockback")
--		if target:getfrozen() == nil then
			kbe = KnockBackEffect:new(target, aspects.fromentity, aspects.knockback)
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

	if target.life <= 0 then
		target:kill()
	end
end

function EntityData:physicaleffectanimation(name, time)
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
	game = self.entity:get_game()
	if game.nodeaths then
		return
	end

	if self.entity.ishero then
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

	self.entity.entitydata = nil
end

function EntityData:drop(hero)
	if hero == nil then hero = self.entity end
	if hero.ishero then
		hero:set_animation("stopped")
		hero:set_tunic_sprite_id("hero/droppedsword")
		hero:freeze()
		hero.isdropped = true
	end
end

function EntityData:throwsword(entitydata2)
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

		movement:set_ignore_obstacles()
--[[
		function movement:on_obstacle_reached()
			movement:stop()
			EntityData:drop(hero)
		end
--]]

		function movement:on_finished()
			entitydata2:bepossessedbyhero()
		end
	end
end

function EntityData:getrandom()
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
	-- throw sword to random entity
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

function EntityData:getclosestentity(x, y)
	mindist = 99999
	minentity = nil

	map = game:get_map()
	hero = self.entity

	for entitydata in self:getotherentities() do
		entity = entitydata.entity
		d = entity:get_distance(x, y)
		if d < mindist then
			mindist = d
			minentity = entity.entitydata
		end
	end

	return minentity
end

function EntityData:throwclosest(mousex, mousey)
--[[
	for entity in self.entity:get_map():get_entities("") do
		if entity.entitydata ~= nil then
			x, y = entity:get_position()
			entity.entitydata:log(x, y)
		end
	end
	print("closest", mousex, mousey, selelse

--]]
	self:log("throwing to closest")
	entity = self:getclosestentity(x, y)
	if entity ~= nil then
		if hero.entitydata ~= nil then
			hero.entitydata:throwsword(entity)
		end
	else
		self:log("couldn't find person to throw to", x, y)
	end
end

function EntityData:gettargetpos()
	if self.entity.ishero then
		return self.entity.targetx, self.entity.targety
	else
		target = self.entity.entitytoattack
		if target ~= nil then
			x, y = target.entity:get_position()
			return x, y
		end
	end
end

purpleclass = EntityData:subclass("purpleclass")

function purpleclass:initialize(entity)
	basestats = {}
	EntityData.initialize(self, entity, "purple", "adventurers/knight", 10, "purple", SwordAbility:new(self), TransformAbility:new(self, "poison"), ShieldAbility:new(self), ChargeAbility:new(self), basestats)
end

function purpleclass:getlogcolor()
	return "95"
end

yellowclass = EntityData:subclass("yellowclass")

function yellowclass:initialize(entity)
	basestats = {}
	EntityData.initialize(self, entity, "yellow", "adventurers/guy2", 10, "yellow", FireballAbility:new(self), TransformAbility:new(self, "electric"), ShieldAbility:new(self), BombThrowAbility:new(self), basestats)
end

function yellowclass:getlogcolor()
	return "93"
end

greenclass = EntityData:subclass("greenclass")

function greenclass:initialize(entity)
	basestats = {}
	EntityData.initialize(self, entity, "green", "adventurers/guy3", 10, "green", SwordAbility:new(self), TransformAbility:new(self, "ap"), ShieldAbility:new(self), ShieldBashAbility:new(self), basestats)
end

function greenclass:getlogcolor()
	return "92"
end

return {EntityData=EntityData, purpleclass=purpleclass, yellowclass=yellowclass, greenclass=greenclass}

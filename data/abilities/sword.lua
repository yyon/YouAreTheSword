local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local math = require "math"

--[[
Effects = require "enemies/effect"
FireEffect = Effects.PhysicalEffect:subclass("SwordSwinging")

function FireEffect:getspritename()
	return "fire"
end

function FireEffect:start(aspect)
	time = aspect.time
	self.firedamage = aspect.damage
	timestep = aspect.timestep

	self:starttick(timestep)

	PhysicalEffect.start(self, time)
end

function FireEffect:tick()
	self.entitydata:dodamage(self.entitydata, self.firedamage, {flame=true, natural=true})
end

function FireEffect:getkey()
	return "FireEffect"
end
--]]

local SwordAbility = Ability:subclass("SwordAbility")

function SwordAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Sword", 50, "sword", 0, 0, true)
end

function SwordAbility:doability()
	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	local d = entitydata:getdirection()
	
	self.entitydata:setanimation("sword")

	self.swordentity = map:create_custom_entity({model="sword", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.swordentity.ability = self
	self.swordentity:start(self:get_appearance())

	self.topsword = map:create_custom_entity({model="sword", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.topsword.ability = self
	self.topsword:start(self:get_appearance(), true)
	
	local transform = self:gettransform()
	if transform == "projectile" then
		local tox, toy = self:gettargetpos()
		self.tox, self.toy = tox, toy

		self.arrowentity = map:create_custom_entity({model="swordbeam", x=x, y=y-35, layer=layer, direction=d, width=w, height=h})
		self.arrowentity:start(self, tox, toy)
	end	

	sol.audio.play_sound("sword" .. math.random(1,3))
end

function SwordAbility:onfinish()
	self.entitydata:setanimation("stopped")

	if self.swordentity ~= nil then
		self.swordentity:remove()
		self.swordentity = nil
	end
	if self.topsword ~= nil then
		self.topsword:remove()
		self.topsword = nil
	end
end

function SwordAbility:attack(entity)
	if not self.entitydata:cantargetentity(entity) then
		return
	end

	local entitydata = entity.entitydata

	local damage = 1
	local aspects = {}
	
	local transform = self:gettransform()
	if transform == "ap" then
		aspects.ap = true
		aspects.dontblock = true
	elseif transform == "electric" then
		aspects.electric = 2000
	elseif transform == "slow" then
		aspects.slow = {sprite = "slow"}
	elseif transform == "fire" then
		aspects.fire = {damage=0.1, time=5000, timestep=500}
	elseif transform == "poison" then
		aspects.poison = {weakness=0.1, time=5000}
	elseif transform == "damage" then
		damage = 2
	elseif transform == "lifesteal" then
		aspects.lifesteal = 1
	elseif transform == "holy" then
		aspects.holy = true
	elseif transform == "dagger" then
	end

	self:dodamage(entitydata, damage, aspects)
end

function SwordAbility:gettransform(entity)
	if entity == nil then
		entity = self.entitydata.entity
	end

	if entity ~= nil then
		if entity.ishero then
			if entity.swordtransform ~= nil then
				return entity.swordtransform
			end
		end
	end

	return "normal"
end

function SwordAbility:get_appearance(entity)
	local transform = self:gettransform(entity)

	local ishero = false
	if entity ~= nil and entity.ishero then ishero = true end
	if self.entitydata ~= nil then
		if self.entitydata.entity.ishero then
			ishero = true
		end
	end

	if transform == "normal" then
		if ishero then
			return "swords/swordanim"
		else
			return "swords/normalsword"
		end
	elseif transform == "ap" then
		return "swords/mace"
	elseif transform == "fire" then
		return "swords/fire"
	elseif transform == "electric" then
		return "swords/electric"
	elseif transform == "poison" then
		return "swords/poison"
	elseif transform == "damage" then
		return "swords/largesword"
	elseif transform == "lifesteal" then
		return "swords/lifesteal"
	elseif transform == "holy" then
		return "swords/holy"
	elseif transform == "dagger" then
		return "swords/dagger"
	elseif transform == "slow" then
		return "swords/slow"
	elseif transform == "projectile" then
		return "swords/glowing"
	end
end

sworddesc = {}
sworddesc.getnameicon = function(transform)
	local name
	local icon
	if transform == "ap" then
		name = "Axe"
		icon = "axe"
	elseif transform == "electric" then
		name = "Electric Sword"
		icon = "electricsword"
	elseif transform == "fire" then
		name = "Fire Sword"
		icon = "firesword"
	elseif transform == "poison" then
		name = "Poisoned Sword"
		icon = "poisonsword"
	elseif transform == "damage" then
		name = "Large Sword"
		icon = "largesword"
	elseif transform == "lifesteal" then
		name = "Lifesteal"
		icon = "lifestealsword"
	elseif transform == "holy" then
		name = "Holy Sword"
		icon = "holysword"
	elseif transform == "dagger" then
		name = "Dagger"
		icon = "dagger"
	elseif transform == "slow" then
		name = "Slow"
		icon = "slowness2"
	elseif transform == "normal" then
		name = "None"
		icon = "sword"
	elseif transform == "projectile" then
		name = "Glowing"
		icon = "projectile"
	end
	return name, icon
end
sworddesc.getdesc = function(transform)
	local desc = ""
	if transform == "normal" then
		desc = desc .. ""
	elseif transform == "projectile" then
		desc = desc .. "Shoots an projectile"
	elseif transform == "ap" then
		desc = desc .. "Does more damage against people with armor"
	elseif transform == "fire" then
		desc = desc .. "Sets enemy on fire"
	elseif transform == "electric" then
		desc = desc .. "Stuns enemy"
	elseif transform == "poison" then
		desc = desc .. "Poison makes enemy do less damage"
	elseif transform == "damage" then
		desc = desc .. "Does more damage"
	elseif transform == "lifesteal" then
		desc = desc .. "Heals user equal to the amount of damage done"
	elseif transform == "holy" then
		desc = desc .. "Does more damage against undead"
	elseif transform == "dagger" then
		desc = desc .. "Swings faster"
	elseif transform == "slow" then
		desc = desc .. [[Makes enemy move slower
Enemy has longer casting time, cooldown time]]
	end
	return desc
end
sworddesc.getstats = function(transform)
	local desc = ""
	if transform == "normal" then
		desc = desc .. "7 dmg"
	elseif transform == "projectile" then
		desc = desc .. "7 dmg"
	elseif transform == "ap" then
		desc = desc .. "10 dmg"
	elseif transform == "fire" then
		desc = desc .. [[7 dmg
fire dmg 1s (7 dmg)]]
	elseif transform == "electric" then
		desc = desc .. [[7 dmg
stun 2s]]
	elseif transform == "poison" then
		desc = desc .. [[7 dmg
poison 5s]]
	elseif transform == "damage" then
		desc = desc .. [[14 dmg]]
	elseif transform == "lifesteal" then
		desc = desc .. [[7 dmg
heals user]]
	elseif transform == "holy" then
		desc = desc .. [[7 dmg
42 dmg against undead]]
	elseif transform == "dagger" then
		desc = desc .. [[7 dmg
2x swing speed]]
	elseif transform == "slow" then
		desc = desc .. [[7 dmg
slowness 15s]]
	end
	return desc
end

function SwordAbility:getdesc()
	local desc = [[Swings sword
Sword transformation abilties affect this ability
Current transformation: ]]
	local name = sworddesc.getnameicon(self:gettransform())
	desc = desc .. name .. "\n\n"
	desc = desc .. sworddesc.getdesc(self:gettransform())
	return desc
end
function SwordAbility:getstats()
	return sworddesc.getstats(self:gettransform())
end

return SwordAbility
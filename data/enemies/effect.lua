local class = require "middleclass"

local math = require "math"

Effect = class("Effect")
-- Generic effects - temporary modifications. actual Effects extend the Effect class

function Effect:initialize(affected, ...)
	-- called when :new() ... is called.
	-- example: FreezeEffect:new(entitydata, 500) -> starts the freeze effect on entitydata
	-- affected is a handle to an actual game object
	-- affected usually points to the entitydata it affects. But it can also point to the game object.
	-- No 2 abilities with the same key can exist at the same time for the same entitydata
	
	if affected.isgame then
		self.game = affected
	else
		self.entitydata = affected
		self.map = self.entitydata.entity:get_map()
	end
	self.affected = affected
	if self:get() ~= nil then
		self:alreadyexists(self:get(), ...)
	else
		self.affected.effects[self:getkey()] = self
		if self.map ~= nil then
			if self.map.effects == nil then
				self.map.effects = {}
			end
			self.map.effects[self] = true
		end
		self.active = true
--		self.entitydata:log("starting effect", self)
		self:start(...)
	end
end

function Effect:alreadyexists(currenteffect)
	-- called if entitydata already has the effect with the same key
	
	print("WARNING! tried to add a new effect when one already exists", self:getkey())
end

function Effect:remove()
	-- call to remove the effect
	
	if not self.active then
--		self.entitydata:log("timer tried to remove", self, "but already removed!")
	else
		self:endeffect()
--		self.entitydata:log("ending effect", self)
		self.affected.effects[self:getkey()] = nil
		if self.map ~= nil then
			self.map.effects[self] = nil
		end
		self.active = false
	end
end

function Effect:forceremove()
	-- remove the effect even if the effect doesn't exist
	
	Effect.remove(self)
end

function Effect:getgame()
	-- get game object
	
	if self.game ~= nil then
		return self.game
	else
		return self.entitydata.entity:get_game()
	end
end

function Effect:removeeffectafter(time)
	-- call this to automatically remove the effect after a wait
	print("going to remove", self, time)
--	if not self.active then
--		self.entitydata:log("timer tried to remove", self, "but already removed!")
--	else
	self.removetimer = sol.timer.start(self:getgame():get_hero(), time, function() self:endtimer() end)
--	end
end
function Effect:getremainingtime()
	return self.removetimer:get_remaining_time()
end
function Effect:endtimer()
	self:remove()
end

function Effect:starttick(timestep)
	-- call this to call the tick() method every timestep
	self.timestep = timestep
	sol.timer.start(self:getgame():get_hero(), self.timestep, function() self:dotick() end) -- starting tick immediately causes strange bugs
end
function Effect:dotick()
	if not self.active then return end
	self:tick()
	sol.timer.start(self:getgame():get_hero(), self.timestep, function() self:dotick() end)
end

function Effect:get(affected)
	-- <Effect Class>:get(entiydata) -> returns active effect of type <Effect Class>
	if affected == nil then affected = self.affected end
	return affected.effects[self:getkey()]
end

-- Overwrite these functions:

function Effect:start()
	-- Actually start the effect
end

function Effect:endeffect()
	-- called when effect is ended
end

function Effect:tick()
	-- called every tick if starttick() was called at the beginning
end

-- Different effects

SimpleTimer = Effect:subclass("SimpleTimer")
-- Simple timer: pass in a time and a function to be called when the timer ends
-- Example: Effects.SimpleTimer(entitydata, 500, function() dosomething() end)

function SimpleTimer:start(time, endfunction)
	self.endfunction = endfunction
	self:removeeffectafter(time)
end
function SimpleTimer:endeffect()
	if self.endfunction ~= nil then
		self.endfunction()
	end
end
function SimpleTimer:getkey()
	return self
end
function SimpleTimer:stop()
	self.endfunction = nil
	self:remove()
end

Ticker = Effect:subclass("Ticker")
function Ticker:start(timestep, tickfunction)
	self.tickfunction = tickfunction
	self:starttick(timestep)
end
function Ticker:tick()
	self.tickfunction()
end
function Ticker:getkey()
	return self
end

PhysicalEffect = Effect:subclass("PhysicalEffect")
-- Displays some animated sprite over the entity
-- Use classes that extend this instead of this class directly

function PhysicalEffect:start(time)
	w,h = self.entitydata.entity:get_size()

	paentity = map:create_custom_entity({model="physicaleffect", x=x, y=y, layer=layer, direction=0, width=w, height=h})
	paentity:start(self, self:getspritename())
	self.paentity = paentity

	if time ~= nil then
		self:removeeffectafter(time)
	end
end

function PhysicalEffect:endeffect()
	self.paentity:finish()
end

function PhysicalEffect:getkey()
	return "physicaleffect" .. self:getspritename()
end

FireEffect = PhysicalEffect:subclass("FireEffect")
-- catches person on fire (draws flames + damages entitydata)
-- Effects.FireEffect:new(entitydata, aspect)
-- aspect.time = time that they will be on fire
-- aspect.damage = damage that they take each timestep
-- aspect.timestep = damage them every timestep

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

ElectricalEffect = PhysicalEffect:subclass("ElectricalEffect")
-- draws electricity over them
-- Use electricalstuneffect instead

function ElectricalEffect:getspritename()
	return "stun"
end

function ElectricalEffect:getkey()
	return "ElectricalEffect"
end

PoisonEffect = PhysicalEffect:subclass("PoisonEffect")
-- draws poison over them
-- use PoisonWeaknessEffect instead

function PoisonEffect:getspritename()
	return "poison"
end

function PoisonEffect:getkey()
	return "PoisonEffect"
end

FreezeEffect = Effect:subclass("FreezeEffect")
-- Prevents the player/AI from moving the person
-- This will stun the person (if for a certain amount of time, use StunEffect instead)
-- or allow the person to be moved from other code
-- Usage: FreezeEffect:new(entitydata)
-- You must call effect:remove() at some point to end this

function FreezeEffect:start(...)
	if self.entitydata.freezeeffects == nil then
		self.entitydata.freezesize = 0
		self.entitydata.freezeeffects = {}
	end
	self.entitydata.freezeeffects[self] = true
	self.entitydata.freezesize = self.entitydata.freezesize + 1
	self.entitydata:log("Freeze level start", self.entitydata.freezesize, self)
	if self.entitydata.freezesize == 1 then
		self:freeze()
	end
	self:startfreezeeffects(...)
end

function FreezeEffect:startfreezeeffects()
end

function FreezeEffect:freeze()
	self.entitydata:log("STARTED FREEZE")
	if self.entitydata.entity.ishero then
		self.entitydata.entity:freeze()
	else
		self.entitydata.entity:tick(self.entitydata.entity.frozenstate)
	end
end

--[[
function FreezeEffect:alreadyexists(currenteffect, ...)
--	currenteffect.count = currenteffect.count + 1
	self.entitydata.stuneffects[self] = true
	self.entitydata:log("Freeze level plus", #self.entitydata.stuneffects, self)
	self:startfreezeeffects(...)
end
--]]

function FreezeEffect:endeffect()
--	currenteffect = self:get()
--	if currenteffect ~= nil then
--		currenteffect.count = currenteffect.count - 1
	self.entitydata.freezeeffects[self] = nil
	self.entitydata.freezesize = self.entitydata.freezesize - 1
	self.entitydata:log("Freeze level minus", self.entitydata.freezesize, self)
	if self.entitydata.freezesize == 0 then
		self:endfreeze()
	end
end

function FreezeEffect:endfreeze()
	self.entitydata:log("ENDED FREEZE")
	if self.entitydata.entity.ishero then
		self.entitydata.entity:unfreeze()
	else
		self.entitydata.entity:resetstate()
	end
end

function FreezeEffect:getkey()
	return self
end

StunEffect = FreezeEffect:subclass("StunEffect")
-- Stuns entity for a certain amount of time
-- Usage: Effects.StunEffect:new(entitydata, time)

function StunEffect:alreadyexists(currenteffect, time)
	FreezeEffect.alreadyexists(self, currenteffect)
	self:removeeffectafter(time)
end

function StunEffect:start(time)
	FreezeEffect.start(self)
	self:removeeffectafter(time)
end

ElectricalStunEffect = StunEffect:subclass("ElectricalStunEffect")
-- Stuns entity for a certain amount of time and draws electricity over them
-- Usage: Effects.ElectricalStunEffect(entitydata, time)

function ElectricalStunEffect:startfreezeeffects(...)
	self.electricaleffect = ElectricalEffect:new(self.entitydata)
--	StunEffect.initialize(self, entitydata, ...)
	StunEffect.startfreezeeffects(...)
end
function ElectricalStunEffect:remove(...)
	self.electricaleffect:remove(...)
	StunEffect.remove(self, ...)
end

KnockBackEffect = FreezeEffect:subclass("KnockBackEffect")
-- Pushes the person back from an effect
-- use <attacker's entitydata>:dodamage(<target's entitydata>, damage, aspects)
-- with aspect.knockback = time
-- instead of using this directly

--[[
function KnockBackEffect:start(fromentitydata, knockbackdist)
	self.entitydata:log("starting knockback")
	FreezeEffect.start(self)

	self:doknockback(fromentitydata, knockbackdist)
end

function KnockBackEffect:alreadyexists(currenteffect, fromentitydata, knockbackdist)
	FreezeEffect.alreadyexists(self, currenteffect)

	self:doknockback(fromentitydata, knockbackdist)
end
--]]

function KnockBackEffect:startfreezeeffects(fromentity, knockbackdist, angle)
	self:removeeffectafter(knockbackdist)

	local x, y = self.entitydata.entity:get_position()
	if angle == nil then
		angle = self.entitydata.entity:get_angle(fromentity) + math.pi
	end
	local movement = sol.movement.create("straight")
	self.movement = movement
	movement:set_speed(250)
	movement:set_angle(angle)
--	movement:set_max_distance(knockbackdist)
	movement:set_smooth(true)
	movement:start(self.entitydata.entity)
	local kbe = self
	self.finished = false
	function movement:on_finished()
		kbe.entitydata:log("finished knockback")
		kbe.finished = true
		kbe:remove()
	end
end

function KnockBackEffect:endeffect()
	print("KNOCKBACKEND")
	FreezeEffect.endeffect(self)
	self.movement:stop()
end

function KnockBackEffect:endtimer()
	if not self.finished then
		self:remove()
	end
end

StatEffect = Effect:subclass("StatEffect")
-- modifies the entitydata's stats for a certain amount of time
-- example: Effects.StatEffect:new(entitydata, "defense", 0, 1000)

function StatEffect:start(stat, newvalue, time)
	self.stat = stat
	self.entitydata.stats[self.stat] = newvalue
	self:removeeffectafter(time)
end
function StatEffect:endeffect()
	self.entitydata.stats[self.stat] = self.entitydata.originalstats[self.stat]
end
function StatEffect:getkey()
	return self
end

PoisonWeaknessEffect = StatEffect:subclass("PoisonWeaknessEffect")
-- poisons person for a certain amount of time
-- Usage: Effects.PoisonWeaknessEffect:new(entitydata, <damage multiplier - poisoned people do less damage>, time)

function PoisonWeaknessEffect:start(weakness, time)
	StatEffect.start(self, "damage", weakness, time)
	self.poisoneffect = PoisonEffect:new(self.entitydata)
end
function PoisonWeaknessEffect:remove(...)
	self.poisoneffect:remove(...)
	StatEffect.remove(self, ...)
end

return {Effect=Effect, PhysicalEffect=PhysicalEffect, FireEffect=FireEffect, ElectricalEffect=ElectricalEffect, FreezeEffect=FreezeEffect, StunEffect=StunEffect, ElectricalStunEffect=ElectricalStunEffect, KnockBackEffect=KnockBackEffect, SimpleTimer=SimpleTimer, Ticker=Ticker, StatEffect = StatEffect, PoisonEffect=PoisonEffect, PoisonWeaknessEffect=PoisonWeaknessEffect}

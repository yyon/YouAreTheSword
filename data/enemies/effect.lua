local class = require "middleclass"

Effect = class("Effect")

function Effect:initialize(affected, ...)
	if affected.isgame then
		self.game = affected
	else
		self.entitydata = affected
	end
	self.affected = affected
	if self:get() ~= nil then
		self:alreadyexists(self:get(), ...)
	else
		self.affected.effects[self:getkey()] = self
		self.active = true
--		self.entitydata:log("starting effect", self)
		self:start(...)
	end
end

function Effect:alreadyexists(currenteffect)
	print("WARNING! tried to add a new effect when one already exists", self:getkey())
end

function Effect:start()
end

function Effect:remove()
	if not self.active then
--		self.entitydata:log("timer tried to remove", self, "but already removed!")
	else
		self:endeffect()
--		self.entitydata:log("ending effect", self)
		self.affected.effects[self:getkey()] = nil
		self.active = false
	end
end

function Effect:forceremove()
	Effect.remove(self)
end

function Effect:endeffect()
end

function Effect:getgame()
	if self.game ~= nil then
		return self.game
	else
		return self.entitydata.entity:get_game()
	end
end

function Effect:removeeffectafter(time)
	print("going to remove", self, time)
--	if not self.active then
--		self.entitydata:log("timer tried to remove", self, "but already removed!")
--	else
	sol.timer.start(self:getgame():get_hero(), time, function() self:endtimer() end)
--	end
end

function Effect:endtimer()
	self:remove()
end

function Effect:starttick(timestep)
	self.timestep = timestep
	sol.timer.start(self:getgame():get_hero(), self.timestep, function() self:dotick() end) -- starting tick immediately causes strange bugs
end

function Effect:dotick()
	if not self.active then return end
	self:tick()
	sol.timer.start(self:getgame():get_hero(), self.timestep, function() self:dotick() end)
end

function Effect:get(affected)
	if affected == nil then affected = self.affected end
	return affected.effects[self:getkey()]
end

SimpleTimer = Effect:subclass("SimpleTimer")
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

function ElectricalEffect:getspritename()
	return "stun"
end

function ElectricalEffect:getkey()
	return "ElectricalEffect"
end

PoisonEffect = PhysicalEffect:subclass("PoisonEffect")

function PoisonEffect:getspritename()
	return "poison"
end

function PoisonEffect:getkey()
	return "PoisonEffect"
end

FreezeEffect = Effect:subclass("FreezeEffect")

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

function StunEffect:alreadyexists(currenteffect, time)
	FreezeEffect.alreadyexists(self, currenteffect)
	self:removeeffectafter(time)
end

function StunEffect:alreadyexists(currenteffect, time)
	FreezeEffect.alreadyexists(self, currenteffect)
	self:removeeffectafter(time)
end

function StunEffect:start(time)
	FreezeEffect.start(self)
	self:removeeffectafter(time)
end

ElectricalStunEffect = StunEffect:subclass("ElectricalStunEffect")

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

function KnockBackEffect:startfreezeeffects(fromentity, knockbackdist)
	self:removeeffectafter(knockbackdist)

	local x, y = self.entitydata.entity:get_position()
	local angle = self.entitydata.entity:get_angle(fromentity) + math.pi
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

function PoisonWeaknessEffect:start(weakness, time)
	StatEffect.start(self, "damage", weakness, time)
	self.poisoneffect = PoisonEffect:new(self.entitydata)
end
function PoisonWeaknessEffect:remove(...)
	self.poisoneffect:remove(...)
	StatEffect.remove(self, ...)
end

return {Effect=Effect, PhysicalEffect=PhysicalEffect, FireEffect=FireEffect, ElectricalEffect=ElectricalEffect, FreezeEffect=FreezeEffect, StunEffect=StunEffect, ElectricalStunEffect=ElectricalStunEffect, KnockBackEffect=KnockBackEffect, SimpleTimer=SimpleTimer, Ticker=Ticker, StatEffect = StatEffect, PoisonEffect=PoisonEffect, PoisonWeaknessEffect=PoisonWeaknessEffect}

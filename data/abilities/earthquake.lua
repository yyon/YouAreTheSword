local class = require "middleclass"
Ability = require "abilities/ability"

EarthquakeAbility= Ability:subclass("EarthquakeAbility")

function EarthquakeAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Earthquake", 20000, "earthquake", 3000, 20000, true, "casting")
end

function EarthquakeAbility:doability()
--[[
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
	self.earthquakeentity = map:create_custom_entity({model="earthquake", x=tox, y=toy, layer=layer, direction=0, width=w, height=h})
	self.earthquakeentity.ability = self
	self.earthquakeentity:start(tox, toy)

	self:finish()
--]]
	self.collided = {}
	self.origpos = {}
	
	for entitydata in self.entitydata:getotherentities() do
		if self:catch(entitydata) then
			self:oncollision(entitydata)
		end
	end
	self:oncollision(self.entitydata)
	
	self.ticker = Effects.Ticker(self.entitydata, 50, function() self:shake() end)
	self.timer = Effects.SimpleTimer(self.entitydata, 1000, function() self:finish() end)
	
	sol.audio.play_sound("earthquake")
	self.soundticker = Effects.Ticker(self.entitydata, 100, function() sol.audio.play_sound("earthquake") end)
end

function EarthquakeAbility:oncollision(entitydata)
	entity2 = entitydata.entity
	
	self.collided[entitydata] = true
	
	x, y = entity2:get_position()
	self.origpos[entitydata] = {x=x, y=y}
	
	self:attack(entitydata)
end

function EarthquakeAbility:attack(entitydata)
	if not self.entitydata:cantarget(entitydata) then
		return
	end
	
	damage = 3
	aspects = {}
	aspects.knockback = 1000
	aspects.dontblock = true
	aspects.knockbackrandomangle = true
	

	self:dodamage(entitydata, damage, aspects)
end

function EarthquakeAbility:onfinish()
	self.ticker:remove()
	self.soundticker:remove()
	self.timer:stop()
	
	self:resetenemypos()
end

function EarthquakeAbility:resetenemypos()
	for entitydata, pos in pairs(self.origpos) do
		entity = entitydata.entity
		if entity ~= nil then
			entity:set_position(pos.x, pos.y)
		end
	end
end

function EarthquakeAbility:shake()
	dx = math.random(-50, 50)
	dy = math.random(-50, 50)
	
	self:resetenemypos()
	for entitydata, iscollided in pairs(self.collided) do
		entity = entitydata.entity
		if entity ~= nil then
			x, y = entity:get_position()
			x, y = x + dx, y + dx
			entity:set_position(x, y)
		end
	end
end


return EarthquakeAbility

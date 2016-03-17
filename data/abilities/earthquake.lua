local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local math = require "math"

local EarthquakeAbility= Ability:subclass("EarthquakeAbility")

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
	print("STARTED EARTHQUAKE")

	self.collided = {}
	self.origpos = {}

	for entitydata in self.entitydata:getotherentities() do
		if self:catch(entitydata, true) then
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
	local entity2 = entitydata.entity

	self.collided[entitydata] = true

	local x, y = entity2:get_position()
	self.origpos[entitydata] = {x=x, y=y}

	self:attack(entitydata)
end

function EarthquakeAbility:attack(entitydata)
	if not self.entitydata:cantarget(entitydata, true) then
		return
	end

	local damage = 3
	local aspects = {}
	aspects.knockback = 1000
	aspects.dontblock = true
	aspects.knockbackrandomangle = true


	self:dodamage(entitydata, damage, aspects)
end

function EarthquakeAbility:onfinish()
	if self.ticker == nil then
		print(debug.traceback())
	end
	self.ticker:remove()
	self.soundticker:remove()
	self.timer:stop()

	self:resetenemypos()
end

function EarthquakeAbility:resetenemypos()
	for entitydata, pos in pairs(self.origpos) do
		local entity = entitydata.entity
		if entity ~= nil then
			entity:set_position(pos.x, pos.y)
		end
	end
end

function EarthquakeAbility:shake()
	local dx = math.random(-50, 50)
	local dy = math.random(-50, 50)

	self:resetenemypos()
	for entitydata, iscollided in pairs(self.collided) do
		local entity = entitydata.entity
		if entity ~= nil then
			local x, y = entity:get_position()
			x, y = x + dx, y + dy
			entity:set_position(x, y)
		end
	end
end


return EarthquakeAbility

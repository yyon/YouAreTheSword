local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local FireballConeAbility = Ability:subclass("FireballConeAbility")

function FireballConeAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Fireball Cone", 800, "fireballcone", 0, 2000, true, "casting")
	self.stats = [[7 fire dmg]]
	self.desc = [[Shoots multiple fireballs]]
end

function FireballConeAbility:doability()
	local tox, toy = self:gettargetpos()
	self.tox, self.toy = tox, toy
	self.angle = self.entitydata.entity:get_angle(tox, toy)
	self.anglediff = 0

	self.ticker = Effects.Ticker(self.entitydata, 50, function() self:dotick() end)
	self.timer = Effects.SimpleTimer(self.entitydata, 300, function() self:finish() end)

	sol.audio.play_sound("fireball")
end

function FireballConeAbility:dotick()
	self:dofireball(self.angle + self.anglediff)
	if self.anglediff ~= 0 then
		self:dofireball(self.angle - self.anglediff)
	end
	self.anglediff = self.anglediff + 0.1
end

function FireballConeAbility:dofireball(angle)
	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	local fireballentity = map:create_custom_entity({model="fireball", x=x, y=y, layer=layer, direction=0, width=w, height=h})
	function fireballentity:isangle() return true end
	function fireballentity:isfast() return false end
	fireballentity:start(self, angle)
	function fireballentity.movement.on_position_changed(movement)
		if math.random() < 0.4 then
			fireballentity:onposchanged()
		end
	end
end

function FireballConeAbility:onfinish()
	self.ticker:remove()
	self.timer:stop()
end

return FireballConeAbility

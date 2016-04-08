local class = require "middleclass"
local Ability = require "abilities/ability"
local Effects = require "enemies/effect"

local SpaceShipProjectile = Ability:subclass("SpaceShipProjectile")

function SpaceShipProjectile:initialize(entitydata)
	Ability.initialize(self, entitydata, "SpaceShipProjectile", 800, "fireball", 1200, 10000, true, "green")
end

function SpaceShipProjectile:doability()
	self.entitydata:setanimation("green")
	self.ticker = Effects.Ticker(self.entitydata, 2000, function() self:firevolley() end)
	self.timer = Effects.SimpleTimer(self.entitydata, 6000, function() self:finish() end)
--	self:firevolley()
--	self:finish()
	self.stats = [[3.5 dmg]]
	self.desc = [[Shoots a barrage of projectiles in a pattern]]
end

function SpaceShipProjectile:firevolley(dx, dy)
	sol.audio.play_sound("laser")
	for i = -3,3 do
		local angle = i * 0.3 + 3 * math.pi / 2
		self:fireproj(0, 0, angle)
		self:fireproj(-78, -59, angle)
		self:fireproj(78, -59, angle)
		self:fireproj(-160, -202, angle)
		self:fireproj(160, -202, angle)
	end
end

function SpaceShipProjectile:fireproj(dx, dy, theangle)
	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata
	x = x + dx
	y = y + dy

	self.fireballentity = map:create_custom_entity({model="spaceshipproj", x=x, y=y, layer=layer, direction=0, width=w, height=h})
--	function self.fireballentity:isangle() return true end
	self.fireballentity.is_angle = true
	self.fireballentity.sprite_name = "bosses/abilities/greenbeam"
--	self.fireballentity.anim = "beam2"
	self.fireballentity.damage = 0.5
	self.fireballentity.speed = 400
	self.fireballentity.rotationframes = 50
	self.fireballentity:start(self, theangle)
end

function SpaceShipProjectile:onfinish()
	self.ticker:remove()
	self.timer:stop()
end

return SpaceShipProjectile

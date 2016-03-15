local class = require "middleclass"
Ability = require "abilities/ability"

SpaceShipProjectile = Ability:subclass("SpaceShipProjectile")

function SpaceShipProjectile:initialize(entitydata)
	Ability.initialize(self, entitydata, "SpaceShipProjectile", 800, "fireball", 0, 200, true, "casting")
end

function SpaceShipProjectile:doability()
--	self.ticker = Effects.Ticker(self.entitydata, 100, function() self:firevolley() end)
--	self.timer = Effects.SimpleTimer(self.entitydata, 2000, function() self:finish() end)
	self:firevolley()
end

function SpaceShipProjectile:firevolley(dx, dy)
	self:fireproj(0, 0)
	self:fireproj(-78, -59)
	self:fireproj(78, -59)
	self:fireproj(-160, -202)
	self:fireproj(160, -202)
	self:finish()
end

function SpaceShipProjectile:fireproj(dx, dy)
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata
	x = x + dx
	y = y + dy

	self.fireballentity = map:create_custom_entity({model="spaceshipproj", x=x, y=y, layer=layer, direction=0, width=w, height=h})
	function self.fireballentity:isangle() return true end
	self.fireballentity:start(self, 3 * math.pi / 2)
end

function SpaceShipProjectile:onfinish()
--	self.ticker:remove()
--	self.timer:stop()
end


return SpaceShipProjectile

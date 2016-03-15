local class = require "middleclass"
Ability = require "abilities/ability"

FireballConeAbility = Ability:subclass("FireballConeAbility")

function FireballConeAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Fireball Cone", 800, "fireballcone", 0, 2000, true, "casting")
end

function FireballConeAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	self.tox, self.toy = tox, toy
	self.angle = self.entitydata.entity:get_angle(tox, toy)
	self.anglediff = 0
	
	self.ticker = Effects.Ticker(self.entitydata, 50, function() self:dotick() end)
	self.timer = Effects.SimpleTimer(self.entitydata, 300, function() self:finish() end)
end
	
function FireballConeAbility:dotick()
	self:dofireball(self.angle + self.anglediff)
	if self.anglediff ~= 0 then
		self:dofireball(self.angle - self.anglediff)
	end
	self.anglediff = self.anglediff + 0.1
end

function FireballConeAbility:dofireball(angle)
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	self.fireballentity = map:create_custom_entity({model="fireball", x=x, y=y, layer=layer, direction=0, width=w, height=h})
	function self.fireballentity:isangle() return true end
	self.fireballentity:start(self, angle)
end

function FireballConeAbility:onfinish()
	self.ticker:remove()
	self.timer:stop()
end

return FireballConeAbility

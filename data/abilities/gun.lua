local class = require "middleclass"
Ability = require "abilities/ability"

GunAbility = Ability:subclass("GunAbility")

function GunAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Gun", 2000, "gun", 0, 2000, true, "gun")
end

function GunAbility:doability()
	self.entitydata:setanimation("gun")
	
	self.ticker = Effects.Ticker(self.entitydata, 100, function() self:shoot() end)
	self.timer = Effects.SimpleTimer(self.entitydata, 850, function() self:finish() end)
end	

function GunAbility:shoot()
	tox, toy = self.entitydata:gettargetpos()
	self.tox, self.toy = tox, toy

	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata

	testerentity = map:create_custom_entity({model="guntest", x=x, y=y-40, layer=layer, direction=0, width=8, height=8})
	testerentity.ability = self
	hitentitydata = testerentity:test(tox, toy)
	
	if hitentitydata ~= nil then
		self:attack(hitentitydata)
	end

	sol.audio.play_sound("gun")
end

function GunAbility:attack(entitydata)
	if not self.entitydata:cantarget(entitydata) then
		return
	end
	
	damage = 0.1
	aspects = {knockback=50}
	
	self:dodamage(entitydata, damage, aspects)
end

function GunAbility:onfinish()
	self.ticker:remove()
	self.timer:stop()
end

return GunAbility

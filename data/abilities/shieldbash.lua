local class = require "middleclass"
Ability = require "abilities/ability"

Effects = require "enemies/effect"

ShieldBashAbility = Ability:subclass("ShieldBashAbility")

function ShieldBashAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "shieldbash", 50, 500, 3000, true)
end
function ShieldBashAbility:doability()
	entity = self.entitydata.entity
	map = entity:get_map()
	x,y,layer = entity:get_position()
	w,h = entity:get_size()
	entitydata = self.entitydata
	self.collided = {}

	print(layer)

	d = entitydata:getdirection()

	self.shieldentity = map:create_custom_entity({model="shieldbash", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.shieldentity.ability = self

--	self.entitydata:setanimation("walking_with_shield")

	self.shieldentity:start("adventurers/shield")

	Effects.SimpleTimer:new(self.entitydata, 400, function() self:finish() end)

	self:attackall()
end
function ShieldBashAbility:onfinish()
	if self.shieldentity ~= nil then
		self.entitydata:setanimation("walking")

		self.shieldentity:remove()
		self.shieldentity = nil
		self.entitydata:log("sword finish 2")
	end
end
function ShieldBashAbility:blockdamage(fromentity, damage, aspects)
	if self.entitydata.entity:get_direction4_to(fromentity.entity) == self.entitydata:getdirection() then
		-- shield can block
		self.entitydata:log("Blocked Damage using shield!")
		aspects.reversecancel = 500
		return 0, aspects
	end

	return damage, aspects
end
function ShieldBashAbility:attackall()
	entity = self.entitydata.entity
	map = entity:get_map()

	for entity2 in self.entitydata:getotherentities() do
		dist = entity:get_distance(entity2.entity)
		if dist <= self.range then
			if entity:get_direction4_to(entity2.entity) == self.entitydata:getdirection() then
				if self.entitydata:cantarget(entity2) then
					if self.collided[entity2] == nil then
						self.collided[entity2] = true

						self:attack(entity2)
					end
				end
			end
		end
	end
end
function ShieldBashAbility:attack(entitydata)
	damage = 1
	aspects = {knockback=300}

	self:dodamage(entitydata, damage, aspects)
end

return ShieldBashAbility

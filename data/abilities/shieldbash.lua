local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local ShieldBashAbility = Ability:subclass("ShieldBashAbility")

function ShieldBashAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Shield Bash", 100, "shieldbash", 0, 2000, true)
end
function ShieldBashAbility:doability()
	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata
	self.collided = {}

	local d = entitydata:getdirection()

	self.shieldentity = map:create_custom_entity({model="shieldbash", x=x, y=y, layer=layer, direction=d, width=w, height=h})
	self.shieldentity.ability = self

--	self.entitydata:setanimation("walking_with_shield")

	self.shieldentity:start("adventurers/shield")

	Effects.SimpleTimer:new(self.entitydata, 400, function() self:finish() end)

	self:attackall()

	sol.audio.play_sound("punch")
end
function ShieldBashAbility:onfinish()
	if self.shieldentity ~= nil then
		self.entitydata:setanimation("walking")

		self.shieldentity:remove()
		self.shieldentity = nil
--		self.entitydata:log("sword finish 2")
	end
end
function ShieldBashAbility:blockdamage(fromentity, damage, aspects)
	if self.entitydata.entity:get_direction4_to(fromentity.entity) == self.entitydata:getdirection() then
		-- shield can block
--		self.entitydata:log("Blocked Damage using shield!")
		aspects.reversecancel = 500
		return 0, aspects
	end

	return damage, aspects
end
function ShieldBashAbility:attackall()
	local entity = self.entitydata.entity
	local map = entity:get_map()

	for entity2 in self.entitydata:getotherentities() do
		local dist = entity:get_distance(entity2.entity)
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
	aspects = {knockback=1000}

	self:dodamage(entitydata, damage, aspects)
end

return ShieldBashAbility

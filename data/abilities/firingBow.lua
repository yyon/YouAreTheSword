local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local FiringBowAbility = Ability:subclass("FiringBowAbility")

function FiringBowAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Bow and Arrow", 500, "bowandarrow", 270, 540, true, "firingbow")
end

function FiringBowAbility:doability()
	local tox, toy = self:gettargetpos()
	self.tox, self.toy = tox, toy

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata
	local d = entitydata:getdirection()

	self.arrowentity = map:create_custom_entity({model="arrow", x=x, y=y-35, layer=layer, direction=0, width=w, height=h})
	if self.arrowentity == nil then self:cancel(); return end
	self.arrowentity.rotationframes = 8
	self.arrowentity.rotationframesoffset = 2
	self.arrowentity.framenegative = true
	self.arrowentity:start(self, tox, toy)

	self.entitydata:setanimation("finishedbow")
	self.timer = Effects.SimpleTimer(self.entitydata, 300, function() self:finish() end)

	sol.audio.play_sound("shoot")
end

function FiringBowAbility:onfinish()
--	print("shit")
--	self.entitydata:setanimation("walking")

end

return FiringBowAbility

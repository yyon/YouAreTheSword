local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local CatShootAbility = Ability:subclass("CatShootAbility")

function CatShootAbility:initialize(entitydata, type)
	self.type = type
	local warmupanim
	local warmuptime
	if type == "fast" then
		warmupanim = "fastshot"
		warmuptime = 400
	elseif type == "power" then
		warmupanim = "powershot"
		warmuptime = 500
	end
	Ability.initialize(self, entitydata, "Cat Shoot", 800, "fireball", warmuptime, 2000, true, warmupanim)
end

function CatShootAbility:doability()
	local tox, toy = self.entitydata:gettargetpos()
	self.tox, self.toy = tox, toy

	local entity = self.entitydata.entity
	local map = entity:get_map()
	local x,y,layer = entity:get_position()
	local w,h = entity:get_size()
	local entitydata = self.entitydata

	self.fireballentity = map:create_custom_entity({model="catproj", x=x, y=y-10, layer=layer, direction=self.entitydata:getdirection(), width=w, height=h})
	self.fireballentity.type = self.type
	self.fireballentity:start(self, tox, toy)

	sol.audio.play_sound("catproj")
	
	local shoottime
	local anim
	if self.type == "fast" then
		shoottime = 200
		anim = "fastshot-end"
	elseif self.type == "power" then
		shoottime = 200
		anim = "powershot-end"
	end
	
	self.entitydata:setanimation(anim)
	
	self.shoottimer = Effects.SimpleTimer(self.entitydata, shoottime, function() self:finish() end)
end

function CatShootAbility:onfinish()
	self.shoottimer:stop()
end

return CatShootAbility

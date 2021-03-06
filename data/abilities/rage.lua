local class = require "middleclass"
local Ability = require "abilities/ability"

local Effects = require "enemies/effect"

local RageAbility = Ability:subclass("Rage")

local Effects = require "enemies/effect"

function RageAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Rage", 1000, "rage", 1000, 10000, true, "casting")
	
	self.stats = [[Rage 15s]]
	self.desc = [[Increases damage for target]]
	
	self.heals = true
end

function RageAbility:doability()
	local tox, toy = self:gettargetpos()
	self.target = self.entitydata:getclosestentity(tox, toy, false, nil, true)
	
	local rageeffect = Effects.RageEffect(self.target)
	
	sol.audio.play_sound("rage")

	self:finish()
end


return RageAbility
local class = require "middleclass"
local Ability = require "abilities/ability"

local PossessAbility = Ability:subclass("PossessAbility")

local Effects = require "enemies/effect"

function PossessAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Possess", 20000, "possess", 500, 10000, true, "casting")
	
	self.desc = [[Possesses target to help fight
re-possessing the person with the sword will cancel the effect]]
end

function PossessAbility:doability()
	local tox, toy = self:gettargetpos()
	self.target = self.entitydata:getclosestentity(tox, toy, true)

	if not self.target.entity.ishero then
		Effects.PossessEffect:new(self.target, self.entitydata.team, 20000)
		sol.audio.play_sound("possess")
		self:finish(true)
	else
		self:finish()
	end
end

return PossessAbility

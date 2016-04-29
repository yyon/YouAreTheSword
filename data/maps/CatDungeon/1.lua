local map = ...

map.dialogprefix = "catdungeon."

local Effects = require "enemies/effect"

function map:on_opening_transition_finished()
	self:startcutscene()
	
	self:say("player", "1", function()
		self:finish()
	end)
end
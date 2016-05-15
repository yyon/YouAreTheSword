local map = ...

map.dialogprefix = "mageboss.map3."

local Effects = require "enemies/effect"

function map:on_opening_transition_finished()
	self:startcutscene()
	
	self:look("player", "boss")
	self:say("player", "1", function()
		self:doend()
	end)
end

function map:doend()
	self:finish()
end
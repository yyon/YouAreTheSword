local map = ...

map.dialogprefix = "tutorial."

local Effects = require "enemies/effect"

function map:on_opening_transition_finished()
	self:startcutscene()
	
	self:say("bard", "1", function()
	self:say("knight", "2", function()
	self:say("bard", "3", function()
	self:say("knight", "4", function()
	self:say("bard", "5", function()
	self:say("knight", "6", function()
		self:doend()
	end)
	end)
	end)
	end)
	end)
	end)
end

function map:doend()
	self:finish()
end

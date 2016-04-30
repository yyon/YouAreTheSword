local map = ...

map.dialogprefix = "spaceship.level1."

local Effects = require "enemies/effect"

function map:on_opening_transition_finished()
	self:startcutscene()
	self:camera("cam_pos")
	self:camera("player")
	self:say("player", "1", function()
	self:say("player", "2", function()
		self:doend()
	end)
	end)
end

function map:doend()
	self:finish()
end

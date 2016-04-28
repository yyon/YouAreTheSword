local map = ...

map.dialogprefix = "dunsmur."

local Effects = require "enemies/effect"

function map:on_opening_transition_finished()
	self:startcutscene()
	
	self:say("dunsmur", "1", function()
		self:choice("2", "Yes", function() self:startdunsmur() end,
			"No", function() self:startadventurer() end)
	end)
end

function map:startdunsmur()
	game.chosedunsmur = true
	
	self:reattachcamera()
	local hero = self:get_hero()
	local dunsmur = self:get_entity("dunsmur")
	hero.entitydata:throwsword(dunsmur.entitydata, true)
	
	self:wait(1000, function()
		self:dunsmurcatch()
	end)
end

function map:dunsmurcatch()
	local hero = self:get_hero()
	hero.entitydata:playerstage()

	self:deattachcamera()
	
	for entity in self:get_entities("") do
		if entity.entitydata ~= nil then
			if entity.entitydata.team == "adventurer" then
				entity.entitydata.team = "monster"
				entity.entitydata.actualteam = "monster"
				entity.entitydata.life = 100
				entity.entitydata.maxlife = 100
			end
		end
	end
	
	self:doend()
end

function map:startadventurer()
	dunsmur.entitydata.cantpossess = true
	
	dunsmur.entitydata:startpuns()
	
	self:doend()
end

function map:doend()
	self:finish()
end

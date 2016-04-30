local map = ...

map.dialogprefix = "tutorial."

local Effects = require "enemies/effect"

function map:on_opening_transition_finished()
	self:startcutscene()
	player.entitydata:setdirection(3)
	spaceship:set_optimization_distance(0)
	inship:set_optimization_distance(0)
	beam:set_optimization_distance(0)
	
	self:move("spaceship", "shipstop1", function()
		beam:set_position(beampos:get_position())
		local movement = sol.movement.create("target")
		self.movement = movement
		movement:set_speed(100)
		movement:set_target(inship)
		movement:start(player)
		player.entitydata:setdirection(3)
		local i = 0
		local d = 3
		local shipx, shipy = spaceship:get_position()
		function movement.on_position_changed()
			hero:set_position(player:get_position())
			i = i + 1
			if i % 5 == 0 then
				d = (d + 1) % 4
				player.entitydata:setdirection(d)
			end
			local x, y = player:get_position()
			if y < shipy + 40 then
				self.newentitypossesseffect:remove()
			end
		end
		function movement.on_finished(movement)
			player:set_position(0, 0)
			beam:set_position(0, 9999)
			self:move("spaceship", "shipstop2", function()
				spaceship:set_position(0, 0)
				self:doend()
			end, nil, 800)
		end
	end, nil, 800)
end

function map:doend()
	self:finish()
	teleport("spaceship/spaceship_1")
end

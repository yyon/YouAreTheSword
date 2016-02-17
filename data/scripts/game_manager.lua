local game_manager = {}

-- controls: c : sword
-- a: possess

possess = sol.main.load_file("scripts/possess")

function game_manager:start_game()
	local exists = sol.game.exists("save1.dat")
	local game = sol.game.load("save1.dat")
	if not exists then
		-- Initialize a new savegame.
		game:set_max_life(12)
		game:set_life(game:get_max_life())
		game:set_ability("lift", 2)
		game:set_ability("sword", 1)--"sprites/hero/sword1")
		game:set_starting_location("combat_test_map")
	end
	game:start()
	possess(game)
end

function sol.main:on_key_pressed(key, modifiers)
	if key == "a" then
		possess:possessrandom()
	end
end

return game_manager


local game_manager = {}

-- controls: c : sword
-- a: possess

possess = sol.main.load_file("scripts/possess")

game = nil

function game_manager:start_game()
	local exists = sol.game.exists("save1.dat")
	game = sol.game.load("save1.dat")
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
	
	hero = game:get_hero()
	if hero.entitydata == nil then
		hero.ishero = true
		hero.is_possessing = true
		hero.entitydata = sol.main.load_file("enemies/entitydata")()
		hero.entitydata:createfromclass(hero, "green")
		hero.entitydata:applytoentity()
		hero:set_sword_sprite_id("")
	end
end

function sol.main:on_key_pressed(key, modifiers)
	if key == "a" then
		possess:possessrandom()
	elseif key == "o" then
		game:get_hero().entitydata:startability("sword")
	end
end

return game_manager


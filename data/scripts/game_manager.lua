local game_manager = {}

game = nil

entitydatas = require "enemies/entitydata"

function game_manager:start_game()
	local exists = sol.game.exists("save1.dat")
	game = sol.game.load("save1.dat")
	if not exists then
		-- Initialize a new savegame.
		game:set_max_life(1)
		game:set_life(game:get_max_life())
--		game:set_ability("lift", 2)
--		game:set_ability("sword", 1)--"sprites/hero/sword1")
		game:set_starting_location("combat_test_map")
	end
	game:start()
	
	hero = game:get_hero()
	if hero.entitydata == nil then
		hero.ishero = true
		hero.is_possessing = true
		hero.entitydata = entitydatas.purpleclass:new(hero)--sol.main.load_file("enemies/entitydata")()
--		hero.entitydata:createfromclass(hero, "purple")
		hero.entitydata:applytoentity()
		hero:set_sword_sprite_id("")
	end
end

function sol.main:on_key_pressed(key, modifiers)
	if game:is_paused() or game:is_suspended() then
		print("PAUSED!")
		return
	end
	
	hero = game:get_hero()
	if hero:get_state() ~= "freezed" then
		if key == "1" then
			hero.entitydata:throwrandom()
		elseif key == "2" then
			hero.entitydata:startability("sword")
		elseif key == "3" then
			hero.entitydata:startability("swordtransform")
		elseif key == "k" then
			hero.entitydata:kill()
		end
	end
end

return game_manager


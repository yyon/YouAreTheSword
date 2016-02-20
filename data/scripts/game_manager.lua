local game_manager = {}

game = nil

entitydatas = require "enemies/entitydata"

local os = require "os"
dvorak = os.getenv("USER") == "yyon" -- TODO: keyboard config

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
	
	game:set_command_keyboard_binding("left", "a")
	game:set_command_keyboard_binding("right", dvorak and "e" or "d")
	game:set_command_keyboard_binding("up", dvorak and "," or "w")
	game:set_command_keyboard_binding("down", dvorak and "o" or "s")
	game:set_command_keyboard_binding("pause", "escape")
	
	width, height = sol.video.get_quest_size()
	sol.video.set_window_size(width*2, height*2)
	sol.video.set_mode("hq2x") -- for some reason this has to be set for the mouse position to work
	
	game:set_pause_allowed(true)
	
	hero = game:get_hero()
	if hero.entitydata == nil then
		hero.ishero = true
		hero.is_possessing = true
		hero.entitydata = entitydatas.purpleclass:new(hero)--sol.main.load_file("enemies/entitydata")()
--		hero.entitydata:createfromclass(hero, "purple")
		hero.entitydata:applytoentity()
		hero:set_sword_sprite_id("")
--		hero:set_walking_speed(64) -- currently slightly higher than NPCs for testing
	end
	
	tick()
end

function convert_to_map(mousex, mousey)
	if mousex == nil then return nil, nil end
	map = game:get_map()
	
	questwidth, questheight = sol.video.get_window_size()
	questwidth, questheight = questwidth * 2, questheight * 2
	
	minx, miny, width, height = map:get_camera_position()
	
	return (minx + (mousex / questwidth * width)), (miny + (mousey / questheight * height))
end

function sol.main:on_key_pressed(key, modifiers)
	if game:is_paused() or game:is_suspended() then
		print("PAUSED!")
		return
	end
	
	mousex, mousey = sol.input.get_mouse_position()
	x, y = convert_to_map(mousex, mousey)
	
	if x ~= nil then
		hero:set_direction(hero:get_direction4_to(x, y))
	end
	
	hero = game:get_hero()
	if hero:get_state() ~= "freezed" then
		if key == "space" then
			hero.entitydata:startability("sword")
		elseif (key == "e" and not dvorak) or (key == "." and dvorak) then
			hero.entitydata:startability("swordtransform")
		elseif key == "left shift" then
			hero.entitydata:startability("block")
		elseif key == "escape" then
			print("TODO: pause menu")
		--debug keys
		elseif key == "r" then
			hero.entitydata:throwrandom()
		elseif key == "k" then
			hero.entitydata:kill()
		end
	end
end

function  sol.main:on_key_released(key, modifiers)
	if game:is_paused() or game:is_suspended() then
		print("PAUSED!")
		return
	end
	
	mousex, mousey = sol.input.get_mouse_position()
	x, y = convert_to_map(mousex, mousey)
	
	if x ~= nil then
		hero:set_direction(hero:get_direction4_to(x, y))
	end
	
	hero = game:get_hero()
	if key == "left shift" then
		print("ending block")
		hero.entitydata:endability("block")
	end
end

function sol.main:on_mouse_pressed(button, ...)
	if game:is_paused() or game:is_suspended() then
		print("PAUSED!")
		return
	end
	
	mousex, mousey = sol.input.get_mouse_position()
	x, y = convert_to_map(mousex, mousey)
	
	if x == nil then
		print("No mouse position!")
		return
	else
		hero:set_direction(hero:get_direction4_to(x, y))
	end
	
	hero = game:get_hero()
	if hero:get_state() ~= "freezed" then
		if button == "right" then
			hero.entitydata:throwclosest(x, y)
		elseif button == "left" then
			hero.entitydata:startability("special", x, y)
		end
	end
end

function tick()
	hero = game:get_hero()
	
	if not (game:is_paused() or game:is_suspended()) then
		mousex, mousey = sol.input.get_mouse_position()
		x, y = convert_to_map(mousex, mousey)
		
		hero.entitydata:tickability(x, y)
--		if sol.input.is_key_pressed("left shift") then
--			if x ~= nil then
--				hero:set_direction(hero:get_direction4_to(x, y))
--			end
--		end
	end
	
	sol.timer.start(hero, 100, function() tick() end)
end

return game_manager


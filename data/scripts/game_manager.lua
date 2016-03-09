local game_manager = {}

local math = require "math"
local os = require "os"
math.randomseed(os.time())
math.random()

game = nil

entitydatas = require "enemies/entitydata"
local hud_manager = require "scripts/hud/hud"

require "pickle"

local os = require "os"
dvorak = os.getenv("USER") == "yyon" -- TODO: keyboard config

function game_manager:start_game()
	load()
	
end

function sol.main:on_key_pressed(key, modifiers)
	hero = game:get_hero()
	if game:is_paused() or game:is_suspended() or hero.entitydata == nil then
		if key == "space" then
			if game.doingdialog then
				game:simulate_command_pressed("action")
				if not game:is_suspended() then
					-- dialog ended
					print("DIALOGEND!")
					game.doingdialog = false
				end
			end
		end
		return
	end

	x, y = hero.entitydata:gettargetpos()
	
	if x ~= nil then
		hero:set_direction(hero:get_direction4_to(x, y))
--		hero.targetx = x
--		hero.targety = y
	end

	if hero:get_state() ~= "freezed" then
		if key == "space" then
			didsomething = false
			
			local map = hero:get_map()
			for entity in map:get_entities("") do
				if entity:get_type() == "npc" then
					if hero:get_distance(entity) < 80 then
						if hero:get_direction4_to(entity) == hero:get_direction() then
							didsomething = true
							
							game.doingdialog = true
							game:start_dialog(entity:get_name())
						end
					end
				end
			end
			
			if not didsomething then
				hero.entitydata:startability("normal")
			end
		elseif (key == "e" and not dvorak) or (key == "." and dvorak) then
			hero.entitydata:startability("swordtransform")
		elseif key == "left shift" then
			hero.entitydata:startability("block")
		elseif key == "escape" then
			print("TODO: pause menu")
		elseif (key == "q" and not dvorak) or (key == "'" and dvorak) then
			hero.entitydata:startability("special", x, y)
		elseif (key == "tab") then
			hero.entitydata:throwclosest(x, y)
		--debug keys
--		elseif key == "r" then
--			hero.entitydata:throwrandom()
		elseif key == "5" then
			saveto(1)
		elseif key == "6" then
			loadfrom(1)
		elseif key == "p" then
			game.dontattack = true
		elseif key == "i" then
			game.nodeaths = true
		elseif key == "k" then
			hero.entitydata:kill()
		elseif (key == "s" and dvorak) or (key == "left alt" and not dvorak) then
			hero:set_walking_speed(500)
		elseif key == "1" or key == "2" or key == "3" or key == "4" then
			if hero.entitydata.cheatyabilityswitcher == nil then
				hero.entitydata.cheatyabilityswitcher = {["1"]=0, ["2"]=0, ["3"]=0, ["4"]=0}
			end
			cheatyabilities = {["1"]=hero.entitydata.normalabilities, ["2"]=hero.entitydata.transformabilities, ["3"]=hero.entitydata.blockabilities, ["4"]=hero.entitydata.specialabilities}
			cheatyabilities = cheatyabilities[key]
			hero.entitydata.cheatyabilityswitcher[key] = hero.entitydata.cheatyabilityswitcher[key] + 1
			if hero.entitydata.cheatyabilityswitcher[key] > #cheatyabilities then
				hero.entitydata.cheatyabilityswitcher[key] = 1
			end
			cheatyability = cheatyabilities[hero.entitydata.cheatyabilityswitcher[key]]
			if key == "1" then
				hero.entitydata.swordability = cheatyability
			elseif key == "2" then
				hero.entitydata.transformability = cheatyability
			elseif key == "3" then
				hero.entitydata.blockability = cheatyability
			elseif key == "4" then
				hero.entitydata.specialability = cheatyability
			end
			print("CHEAT: ability changed to", cheatyability.name)
		end
	end

	if key == "f4" and modifiers.alt then
            -- Alt + F4: stop the program.
            sol.main.exit()
          end
end

function  sol.main:on_key_released(key, modifiers)
	hero = game:get_hero()
	if game:is_paused() or game:is_suspended() or hero.entitydata == nil then
		print("PAUSED!")
		return
	end

--	mousex, mousey = sol.input.get_mouse_position()
--	x, y = convert_to_map(mousex, mousey)
	x, y = hero.entitydata:gettargetpos()

	if x ~= nil then
		hero:set_direction(hero:get_direction4_to(x, y))
	end

	hero = game:get_hero()
	if key == "space" then
		hero.entitydata:keyrelease("normal")
	elseif (key == "e" and not dvorak) or (key == "." and dvorak) then
		hero.entitydata:keyrelease("swordtransform")
	elseif key == "left shift" then
		hero.entitydata:keyrelease("block")
	end
end

function sol.main:on_mouse_pressed(button, ...)
	hero = game:get_hero()
	if game:is_paused() or game:is_suspended() or hero.entitydata == nil then
		print("PAUSED!")
		return
	end

--	mousex, mousey = sol.input.get_mouse_position()
--	x, y = convert_to_map(mousex, mousey)
	x, y = hero.entitydata:gettargetpos()

	if x == nil then
		print("No mouse position!")
		return
	else
		hero:set_direction(hero:get_direction4_to(x, y))
		hero.targetx = x
		hero.targety = y
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
	
	if not (game:is_paused() or game:is_suspended() or hero.entitydata == nil) then
		if hero.entitydata ~= nil then
			for entity in hero:get_map():get_entities("") do
				if entity.get_destination_map ~= nil then
					if hero:overlaps(entity) then
						print("TELEPORT!")
						if hero:get_map().effects ~= nil then
							while true do
								foundeffect = false
								for effect, b in pairs(hero:get_map().effects) do
									foundeffect = true
									effect:remove()
								end
								if not foundeffect then
									break
								end
							end
						end
						hero:teleport(entity:get_destination_map(), entity:get_destination_name(), entity:get_transition())
					end
				end
			end
		end
	
		soulsdrop = 0.001
		if hero.entitydata.team == "monster" then
			soulsdrop = 0.01
		end
		hero.souls = hero.souls - soulsdrop
		if hero.souls < 0 then hero.souls = 0 end

--		mousex, mousey = sol.input.get_mouse_position()
--		x, y = convert_to_map(mousex, mousey)
		x, y = hero.entitydata:gettargetpos()

		hero.entitydata:tickability(x, y)

		if sol.input.is_key_pressed("left shift") then
			if x ~= nil then
				if hero.entitydata.usingability == nil then
					hero.entitydata:startability("block", true)
				end
--				hero:set_direction(hero:get_direction4_to(x, y))
			end
		end
	end

	sol.timer.start(hero, 50, function() tick() end)
end

function luastrsanitize(str)
	str=str:gsub("\\","\\\\")  --replace  with 
	str=str:gsub("\"","\\\"")    --replace " with "
	str=str:gsub("\n","\\n")    --replace " with "
	return str
end

function save()
	print("save")
	
	hero = game:get_hero()
	entitydata = hero.entitydata
	entitydatatable = entitydata:totable()
	
	usersave = {}
	usersave.hero = entitydatatable
	usersave.souls = hero.souls
	usersave.swordhealth = hero.swordhealth
	usersave.maxswordhealth = hero.maxswordhealth
	
	pickleduserdata = pickle(usersave)
	pickleduserdata = luastrsanitize(pickleduserdata)
	game:set_value("usersave", pickleduserdata)
	
	game:save()
end

function copy(from, to)
	if sol.file.exists(to) then
		sol.file.remove(to)
	end
	
	fromfile = sol.file.open(from, "r")
	
	if fromfile ~= nil then
		savetext = fromfile:read("*all")
		
		tofile = sol.file.open(to, "w")
		if tofile ~= nil then
			tofile:write(savetext)
			tofile:close()
		end
		fromfile:close()
	end
end

function saveto(name)
	save()
	
	savename = "save" .. name .. ".dat"
	copy("save.dat", savename)
end

function loadfrom(name)
	savename = "save" .. name .. ".dat"
	copy(savename, "save.dat")
	
	load()
end

function load()
	savefile = "save.dat"

	local exists = sol.game.exists(savefile)
	game = sol.game.load(savefile)
	if not exists then
		-- Initialize a new savegame.
		game:set_max_life(12)
		game:set_life(game:get_max_life())
--		game:set_ability("lift", 2)
--		game:set_ability("sword", 1)--"sprites/hero/sword1")
		game:set_starting_location("test2")
	end
	game:start()
	
	
	game:set_command_keyboard_binding("left", "a")
	game:set_command_keyboard_binding("right", dvorak and "e" or "d")
	game:set_command_keyboard_binding("up", dvorak and "," or "w")
	game:set_command_keyboard_binding("down", dvorak and "o" or "s")
	game:set_command_keyboard_binding("pause", "escape")
	game:set_command_keyboard_binding("action", "")
	game:set_command_keyboard_binding("attack", "")
	game:set_command_keyboard_binding("item_1", "")
	game:set_command_keyboard_binding("item_2", "")

	width, height = sol.video.get_quest_size()
--	sol.video.set_window_size(width*2, height*2)
	sol.video.set_mode("normal") -- for some reason this has to be set for the mouse position to work
	sol.video.set_window_size(width, height)

	game:set_pause_allowed(true)
	local hud = hud_manager:create(game)

	hero = game:get_hero()
	hero.ishero = true
	hero.is_possessing = true
	
	usersave = game:get_value("usersave")
	print("unpickle", pickledheroentitydata)
	if usersave ~= nil then
		usersave = unpickle(usersave)
		entitydatas.EntityData.static:fromtable(usersave.hero, hero)
		hero.souls = usersave.souls
		hero.swordhealth = usersave.swordhealth
		hero.maxswordhealth = usersave.maxswordhealth
	end
	
	if hero.entitydata == nil then
		print("START")
		hero.souls = 1
		hero.swordhealth = 100
		hero.maxswordhealth = 100
		hero.entitydata = entitydatas.yellowclass:new(hero)--sol.main.load_file("enemies/entitydata")()
--		hero.entitydata:createfromclass(hero, "purple")
	end
	
	hero.entitydata.entity = hero
	hero.entitydata:applytoentity()
	
	hero:set_sword_sprite_id("")
	hero:set_walking_speed(128)
	
	hero.eyessprite = sol.sprite.create("adventurers/eyes")
	function hero:on_position_changed(x, y, layer)
		if self.entitydata ~= nil then
			self.entitydata:updatechangepos(x,y,layer)
		end
	end
	
	game.lifebarsprite = sol.sprite.create("hud/lifebar")
	game.allieslifebarsprite = sol.sprite.create("hud/allieslifebar")
	
	function game:on_map_changed(map)
		save()
		
		function map:on_draw(dst_surface)
			hero = map:get_hero()
			if hero.entitydata ~= nil then
				if not hero.entitydata.cantdraweyes then
					if hero:is_visible() then
						anim = hero:get_animation()
						if hero.eyessprite:has_animation(anim) then
							if anim ~= hero.eyessprite:get_animation() then
								hero.eyessprite:set_animation(anim)
							end
							d = hero:get_direction()
							if hero.eyessprite:get_num_directions() < d then
								d = 0
							end
							hero.eyessprite:set_direction(d)
					
							x, y = hero:get_position()
							map:draw_sprite(hero.eyessprite, x, y)
						end
					end
				end
			end
			
			for entity in self:get_entities("") do
				if entity.entitydata ~= nil then
					x, y = entity:get_position()
					y = y - 65
					
					if entity.entitydata.life > 0 then
						frame = math.floor((1 - entity.entitydata.life / entity.entitydata.maxlife) * 49)
					else
						frame = 49
					end
					
					lifebarsprite = game.lifebarsprite
					if entity.entitydata.team == "adventurer" then
						lifebarsprite = game.allieslifebarsprite
					end
					lifebarsprite:set_frame(frame)
					map:draw_sprite(lifebarsprite, x, y)
				end
			end
		end
	end

	game.isgame = true
	game.effects = {}

	tick()
end

return game_manager

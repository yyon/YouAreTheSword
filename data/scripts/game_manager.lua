local builtinglobals = {Pickle=true, game=true, _profiler_hook_wrapper_by_time=true, _profiler=true, luastrsanitize=true, pickle=true, save=true, load=true, deletesave=true, loadfrom=true, saveexists=true, unpickle=true, canmoveto=true, targetstopper=true, movementaccuracy=true, _profiler_hook_wrapper_by_call=true}
for k,v in pairs( _G ) do
--	print( k .. " =&gt; ", v )
	builtinglobals[k]=true
end

local game_manager = {}

local math = require "math"
local os = require "os"
math.randomseed(os.time())
math.random()

local EntityDatas = require "enemies/entitydata"

game = nil

local entitydatas = require "enemies/entitydata"
local hud_manager = require "scripts/hud/hud"
local dialogmenu = require "menus/dialog"
local abhelpmenu = require "menus/abilityhelp"
local pause_manager = require("menus/pause")
local keyconfmenu = require "menus/keyconfig"
local pause_menu

require "pickle"

local os = require "os"

local Effects = require "enemies/effect"

require "profiler"

_movements = {}
local actualcreatemovement = sol.movement.create
function sol.movement.create(movementtype, ...)
	local movement = actualcreatemovement(movementtype, ...)

	movement.actualsettarget = movement.set_target
	function movement:set_target(entity, ...)
		if entity ~= nil and type(entity) ~= "number" and entity.exists ~= nil then
			self.target = entity
		end
		self:actualsettarget(entity, ...)
	end

	movement.actualstart = movement.start
	function movement:start(entity, ...)
		_movements[entity] = self
		self:actualstart(entity, ...)
	end

	return movement
end

function game_manager:start_game()
	load()

end

local function onkey(k, released)
	local hero = game:get_hero()

	local x, y = hero.entitydata:gettargetpos()
	
	local action 
	for a, keylist in pairs(conf.keys) do
		for i, key in pairs(keylist) do
			if key == k then
				action = a
			end
		end
	end
	
	if action == nil then return false end
	
	if game:is_paused() or game:is_suspended() or hero.entitydata == nil then
		if action == "normal" then
			if game.dialog ~= nil then
				if game.dialog.isshowingdialog then
					game.dialog:showscreen()
				end
			end
		elseif action == "abilityhelp" and released then
			if game.helpmenu ~= nil then
				sol.menu.stop(game.helpmenu)
				game:set_paused(false)
				game.dontshowpausemenu = false
			end
		end
		return
	end
	
	print(action)
	
	if not released then
		if action == "pause" then
			game:set_paused(true)
		elseif action == "swordtransform" then
			hero.entitydata:startability("swordtransform")
		elseif action == "throwallies" then
			hero.entitydata:throwclosest(true)
		elseif action == "throwenemies" then
			hero.entitydata:throwclosest(false)
		elseif action == "throwany" then
			hero.entitydata:throwclosest(x, y)
		elseif action == "special" then
			hero.entitydata:startability("special", x, y)
		elseif action == "block" then
			hero.entitydata:startability("block")
		elseif action == "normal" then
			local didsomething = false
	
			local map = hero:get_map()
			for entity in map:get_entities("") do
				if entity.dialog ~= nil then
					if hero:get_distance(entity) < 80 then
						if hero:get_direction4_to(entity) == hero:get_direction() then
							didsomething = true
							if entity.entitydata ~= nil then
							local d = entity:get_direction4_to(hero)
								entity.entitydata:setdirection(d)
							end

							game:start_dialog(entity.dialog)
						end
					end
				end
				if entity:get_type() == "npc" then
					if hero:get_distance(entity) < 80 then
						if hero:get_direction4_to(entity) == hero:get_direction() then
							local name = entity:get_name()
							if name ~= nil then
								didsomething = true
	
								game:start_dialog(name)
							end
						end
					end
				end
			end
	
			if not didsomething then
				hero.entitydata:startability("normal")
			end
		elseif action == "abilityhelp" then
			game.helpmenu = abhelpmenu:new(game)
			sol.menu.start(game, game.helpmenu)
			game.dontshowpausemenu = true
			game:set_paused(true)
		end
	elseif released then	
		if action == "normal" then
			hero.entitydata:keyrelease("normal")
		elseif action == "block" then
			hero.entitydata:keyrelease("block")
		elseif action == "special" then
			hero.entitydata:keyrelease("special")
		elseif action == "swordtransform" then
			hero.entitydata:keyrelease("swordtransform")
		end
	end
	
	return true
end

function sol.main:on_key_pressed(key, modifiers)
	if game == nil or game:is_paused() then
		keyhandler(key, modifiers)
		return
	end

	local hero = game:get_hero()
	
	local result = onkey(key)
	if result then return end

	if key == "p" then
		if game.dontattack then
			print("ended cheat: AIs don't attack")
			game.dontattack = nil
		else
			print("cheat: AIs don't attack")
			game.dontattack = true
		end
	elseif key == "i" then
		if game.nodeaths then
			print("ended cheat: invincibility")
			game.nodeaths = nil
		else
			print("cheat: invincibility")
			game.nodeaths = true
		end
	elseif key == "b" then
		print("cheat: catch everyone")
		for entity in game:get_map():get_entities("") do
			if entity.entitydata ~= nil then
				print("caught", entity.entitydata.theclass)
				entity.entitydata.caught = true
			end
		end
		if hero.entitydata ~= nil then
			hero.entitydata.caught = true
		end
	elseif key == "j" then
		if game.nocooldown then
			print("ended cheat: no cooldown")
			game.nocooldown = nil
		else
			print("cheat: cooldown")
			game.nocooldown = true
		end
	elseif key == "[" then
		massacre = {}
		for entity in game:get_map():get_entities("") do
			if entity.entitydata ~= nil then
				local theclassname = entity.entitydata.class.name
				local x, y = entity:get_position()
				massacre[theclassname] = {x=x,y=y}
				entity.entitydata:kill()
			end
		end
	elseif key == "]" then
		for theclassname, pos in pairs(massacre) do
			local map = hero:get_map()

			local newentity = map:create_enemy({
				breed="enemy_constructor",
				layer=0,
				x=pos.x,
				y=pos.y,
				direction=0
			})

			local angelentitydata = _EntityDatas[theclassname]:new()
			angelentitydata.entity = newentity
			angelentitydata:applytoentity()
		end
	elseif key == "z" then
		if game.bypassteleport then
			print("ended cheat: bypass teleport")
			game.bypassteleport = nil
		else
			print("cheat: bypass teleport (allows you to go between maps without defeating all the enemies)")
			game.bypassteleport = true
		end
	elseif key == "k" then
		print("cheat: dropped sword")
		lastentitydata = hero.entitydata
		hero.entitydata:kill()
	elseif key == ":" then
		print("cheat: resurrected")
		if lastentitydata ~= nil then
			lastentitydata:bepossessedbyhero()
		end
	elseif (key == "s" and dvorak) or (key == "o" and not dvorak) then
		if hero:get_walking_speed() == 500 then
			print("ended cheat: fast walk")
			hero:set_walking_speed(128)
		else
			print("cheat: fast walk")
			hero:set_walking_speed(500)
		end
	elseif key == "/" then
		if not startedprofiler then
			print("started profiler")
			startedprofiler = true
			profiler = newProfiler()
			profiler:start()
		else
			print("stopped profiler")
			profiler:stop()
			local outfile = io.open( "profile.txt", "w+" )
			profiler:report( outfile, true )
			outfile:close()
			startedprofiler = false
		end
	elseif key == "n" then
		print("started lines")
		function trace (event, line)
			local s = debug.getinfo(2).short_src
			print(s .. ":" .. line)
		end

		debug.sethook(trace, "l")
	elseif key == "m" then
		if game.muted then
			print("unmuted")
			game.muted = nil
			sol.audio.set_sound_volume(100)
			sol.audio.set_music_volume(100)
		else
			print("muted")
			game.muted = true
			sol.audio.set_sound_volume(0)
			sol.audio.set_music_volume(0)
		end
	elseif key == "g" then
		for k,v in pairs( _G ) do
			if not builtinglobals[k] then
				print( k .. " =&gt; ", v )
			end
		end
	elseif key == "t" then
		local entitydata = hero.entitydata:getclosestentity(hero.entitydata:gettargetpos())
		entitydata:kill()
	elseif key == "u" then
		if hero.entitydata.usingability ~= nil then
			hero.entitydata.usingability:cancel()
		end
	elseif key == "f" then
		if game.fastthrow then
			print("ended cheat: fast throw")
			game.fastthrow = false
		else
			print("cheat: fast throw")
			game.fastthrow = true
		end
	elseif key == "r" then
		if hero.entitydata ~= nil then
			local x, y = hero:get_position()
			hero.entitydata:throwclosest(true)
			hero.entitydata:throwclosest(true)
		end
	elseif key == "h" then
		configsave()
	elseif key == "x" then
		configload()
	end
	
	local x, y = hero.entitydata:gettargetpos()

	if x == nil then
		print("COULDN'T FIND MOUSE")
		return
	end

	hero:set_direction(hero:get_direction4_to(x, y))

	if key == "-" then
		self.keyconfmenu = keyconfmenu:new(game)
		sol.menu.start(game, self.keyconfmenu)
		game.dontshowpausemenu = true
		game:set_paused(true)
	--debug keys
--		elseif key == "r" then
--			hero.entitydata:throwrandom()
	elseif key == "5" then
		print("cheat: saved game")
		saveto(1)
	elseif key == "6" then
		print("cheat: loaded game")
		loadfrom(1)
	elseif key == "7" then
		print("cheat: restarted game")
		deletesave(1)
		loadfrom(1)
	elseif key == "1" or key == "2" or key == "3" or key == "4" then
		if hero.entitydata.cheatyabilityswitcher == nil then
			hero.entitydata.cheatyabilityswitcher = {["1"]=0, ["2"]=0, ["3"]=0, ["4"]=0}
		end
		local cheatyabilities = {["1"]=hero.entitydata.normalabilities, ["2"]=hero.entitydata.blockabilities, ["3"]=hero.entitydata.transformabilities, ["4"]=hero.entitydata.specialabilities}
		local cheatyabilities = cheatyabilities[key]
		hero.entitydata.cheatyabilityswitcher[key] = hero.entitydata.cheatyabilityswitcher[key] + 1
		if hero.entitydata.cheatyabilityswitcher[key] > #cheatyabilities then
			hero.entitydata.cheatyabilityswitcher[key] = 1
		end
		cheatyability = cheatyabilities[hero.entitydata.cheatyabilityswitcher[key]]
		if key == "1" then
			hero.entitydata.swordability = cheatyability
		elseif key == "2" then
			hero.entitydata.blockability = cheatyability
		elseif key == "3" then
			hero.entitydata.transformability = cheatyability
		elseif key == "4" then
			hero.entitydata.specialability = cheatyability
		end
		print("CHEAT: ability changed to", cheatyability.name)
		if hero.entitydata.theclass == "debugger" then
			hero.entitydata:onabilitychanged()
		end
	elseif key == "c" then
		for num, ability in pairs({hero.entitydata.swordability, hero.entitydata.blockability, hero.entitydata.transformability, hero.entitydata.specialability}) do
			if ability.usingcooldown then
				ability.cooldowntimer:remove()
			end
		end
	end

	if key == "f4" and modifiers.alt then
            -- Alt + F4: stop the program.
            sol.main.exit()
          end
end



function sol.main:on_key_released(key, modifiers)
	if game == nil then
		return
	end

	if (key == "left alt") then
		if self.helpmenu ~= nil then
			sol.menu.stop(self.helpmenu)
			game:set_paused(false)
			game.dontshowpausemenu = false
		end
	end

	if game:is_paused() or game:is_suspended() then
		return
	end

	local hero = game:get_hero()
	if hero.entitydata == nil then
		return
	end

--	mousex, mousey = sol.input.get_mouse_position()
--	x, y = convert_to_map(mousex, mousey)
	local x, y = hero.entitydata:gettargetpos()

	if x ~= nil then
		hero:set_direction(hero:get_direction4_to(x, y))
	end

	local result = onkey(key, true)
	if result then return end
end

function sol.main:on_mouse_pressed(button, ...)
	if game == nil or game:is_paused() then
		mousehandler(button, ...)
		return
	end

	local hero = game:get_hero()
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
	
	button = button .. "_mouse"
	
	local result = onkey(button)
	if result then return end
end

function tick()
	if game.hasended then
		game.hasended = false
		load()
		return
	end


	local hero = game:get_hero()
	local map = game:get_map()

	if not (game:is_paused() or game:is_suspended() or hero.entitydata == nil) then
		if hero.entitydata ~= nil then
			for entity in hero:get_map():get_entities("") do
				if entity.get_destination_map ~= nil then
					if hero:overlaps(entity) then
						if game.bypassteleport or hero.entitydata:getremainingmonsters() == 0 then
							for entity in hero:get_map():get_entities("") do
								entity.removed = true
							end

							if hero.entitydata.usingability ~= nil then
								hero.entitydata.usingability:cancel()
							end

							if hero:get_map().effects ~= nil then
								while true do
									local foundeffect = false
									for effect, b in pairs(hero:get_map().effects) do
										foundeffect = true
										pcall(function() effect:forceremove() end)
										hero:get_map().effects[effect:getkey()] = nil -- just to make sure
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
		end

		if hero.entitydata ~= nil then
			local soulsdrop = 0.0005
			if hero.entitydata.team == "monster" then
				soulsdrop = 0.01
			elseif hero.entitydata.team == "dunsmur" then
				soulsdrop = 0
			end
			if map.nomonstersleft then
				soulsdrop = 0
			end
			hero.entitydata.souls = hero.entitydata.souls - soulsdrop
			if hero.entitydata.souls < 0 then
				hero.entitydata.souls = 0
				if hero.entitydata.team == "monster" and not game.nodeaths then
					hero.entitydata:dropsword()
				end
			end

			local x, y = hero.entitydata:gettargetpos()

			hero.entitydata:tickability(x, y)

			if sol.input.is_key_pressed("left shift") then
				if x ~= nil then
					if hero.entitydata.usingability == nil then
						hero.entitydata:startability("block", true)
					end
				end
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
function luastrunsanitize(str)
	str=str:gsub("\\\\","\\")  --replace  with
	str=str:gsub("\\\"","\"")    --replace " with "
	str=str:gsub("\\n","\n")    --replace " with "
	return str
end

function save()
--	print("save")

	local hero = game:get_hero()
	local entitydata = hero.entitydata
	local entitydatatable = entitydata:totable()

	local usersave = {}
	usersave.hero = entitydatatable
--	usersave.souls = hero.souls
	usersave.swordhealth = hero.swordhealth
	usersave.maxswordhealth = hero.maxswordhealth
	usersave.swordtransform = hero.swordtransform

	local pickleduserdata = pickle(usersave)
	pickleduserdata = luastrsanitize(pickleduserdata)
	game:set_value("usersave", pickleduserdata)

	game:set_value("music", sol.audio.get_music_volume())
	game:set_value("sound", sol.audio.get_sound_volume())

	game:save()
end

local function copy(from, to)
	if sol.file.exists(to) then
		sol.file.remove(to)
	end

	local fromfile = sol.file.open(from, "r")

	if fromfile ~= nil then
		savetext = fromfile:read("*all")

		local tofile = sol.file.open(to, "w")
		if tofile ~= nil then
			tofile:write(savetext)
			tofile:close()
		end
		fromfile:close()
	end
end

function saveto(name)
	save()

	local savename = "save" .. name .. ".dat"
	copy("save.dat", savename)
end

function deletesave(name)
	local savename = "save" .. name .. ".dat"
	sol.file.remove(savename)
end

function loadfrom(name)
	local savename = "save" .. name .. ".dat"
	if sol.file.exists(savename) then
		copy(savename, "save.dat")
	else
		sol.file.remove("save.dat")
	end

	load()
end

function saveexists(name)
	local savename = "save" .. name .. ".dat"
	return sol.file.exists(savename)
end

function load()
	local savefile = "save.dat"

	local exists = sol.game.exists(savefile)
	game = sol.game.load(savefile)

	if not exists then
		-- Initialize a new savegame.
		game:set_max_life(12)
		game:set_life(game:get_max_life())
--		game:set_ability("lift", 2)
--		game:set_ability("sword", 1)--"sprites/hero/sword1")
		game:set_starting_location("hub")
	end
	
	configload()
	
	game:start()

	game:set_ability("sword", 0)
	game:set_ability("sword_knowledge", 0)
	game:set_ability("shield", 0)
	game:set_ability("lift", 0)
	game:set_ability("swim", 0)
	game:set_ability("detect_weak_walls", 0)
	
	updatekeys()

--	local width, height = sol.video.get_quest_size()
--	sol.video.set_window_size(width*2, height*2)
--	sol.video.set_mode("normal") -- for some reason this has to be set for the mouse position to work
--	sol.video.set_window_size(width, height)

	game:set_pause_allowed(true)
	pause_menu = pause_manager:create(game)
	local hud = hud_manager:create(game)

	local hero = game:get_hero()
	hero.ishero = true
	hero.is_possessing = true

	sol.audio.set_music_volume(game:get_value("music") or 100)
	sol.audio.set_sound_volume(game:get_value("sound") or 100)

	local usersave = game:get_value("usersave")
--	print("unpickle", pickledheroentitydata)
	if usersave ~= nil then
		usersave = unpickle(usersave)
		entitydatas.EntityData.static:fromtable(usersave.hero, hero)
--		hero.souls = usersave.souls
		hero.swordhealth = usersave.swordhealth
		hero.maxswordhealth = usersave.maxswordhealth
		hero.swordtransform = usersave.swordtransform
	end

	if hero.entitydata == nil then
		print("START")
--		hero.souls = 1
		hero.swordhealth = 100
		hero.maxswordhealth = 100
		hero.entitydata = entitydatas.knightclass:new(hero)--sol.main.load_file("enemies/entitydata")()
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
	game.herolifebarsprite = sol.sprite.create("hud/herolifebar")
	game.soulbarsprite = sol.sprite.create("hud/soulbar")

	function game:on_map_changed(map)
		save()

		sol.main.load_file("scripts/map")(map)
	end

	game.actually_start_dialog = game.start_dialog
	function game:start_dialog(dialog, ...)
		game.doingdialog = true
		if self:get_map().dialogprefix ~= nil then
			dialog = self:get_map().dialogprefix .. dialog
		end
		game:actually_start_dialog(dialog, ...)
	end
	function game:on_dialog_started(...)
		self.dialog = dialogmenu:new(self)
		sol.menu.start(self, self.dialog)
		self.dialog:ondialog(...)
	end
	game.startdialog = game.start_dialog
	function game:on_dialog_finished(...)
		sol.menu.stop(self.dialog)
	end

	function game:on_paused()
		if not game.dontshowpausemenu then
			hud:on_paused()
			sol.menu.start(game, pause_menu, false)
		end
	end

	function game:on_unpaused()
		hud:on_unpaused()
		sol.menu.stop(pause_menu)
	end

	game.isgame = true
	game.effects = {}

	tick()
end

function configsave()
	if conf == nil then conf = {} end

	local conffile = sol.file.open("conf", "w")

	local conftext = pickle(conf)
	conftext = luastrsanitize(conftext)

	conffile:write(conftext)

	conffile:close()
end

function configload()
	local conffile = sol.file.open("conf", "r")
	local conftext = conffile:read()
	conftext = luastrunsanitize(conftext)
	
	conf = unpickle(conftext)
	
	if conf.keys == nil then
		conf.keys = {
			left={"a"},
			up={"w"},
			down={"s"},
			right={"d"},
			pause={"escape"},
			swordtransform={"e"},
			throwallies={"right_mouse"},
			throwenemies={"middle_mouse"},
			throwany={"tab"},
			special={"left_mouse", "q"},
			block={"left shift"},
			normal={"space"},
			abilityhelp={"left alt"}
		}
	end
	
	conffile.close()
end

function updatekeys()
	game:set_command_keyboard_binding("left", conf.keys.left[1])
	game:set_command_keyboard_binding("right", conf.keys.right[1])
	game:set_command_keyboard_binding("up", conf.keys.up[1])
	game:set_command_keyboard_binding("down", conf.keys.down[1])
	game:set_command_keyboard_binding("pause", "")
	game:set_command_keyboard_binding("action", "")
	game:set_command_keyboard_binding("attack", "")
	game:set_command_keyboard_binding("item_1", "")
	game:set_command_keyboard_binding("item_2", "")
end

return game_manager

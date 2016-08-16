--makes the HUD

local hud_manager = {}

function hud_manager:create(game)
	local hud = {
		enabled = false,
		elements = {},
		top_left_opacity = 255,
		custom_command_effects = {},
	}

	local health_builder = require("scripts/hud/health")
	local soul_builder = require("scripts/hud/possess_o_meter")
	local sword_health_builder = require("scripts/hud/sword_health")
	local person_status_builder = require("scripts/hud/personstatus")
	local sword_status_builder = require("scripts/hud/swordstatus")
	local remaining_status_builder = require("scripts/hud/remainingstatus")

--	menu = health_builder:new(game)
--  	menu:set_dst_position(0, 10)
--  	hud.elements[#hud.elements + 1] = menu

	local menu = soul_builder:new(game)
  	menu:set_dst_position(10, 65)
  	hud.elements[#hud.elements + 1] = menu
	menu.group = 1

	local menu = sword_health_builder:new(game)
  	menu:set_dst_position(10, 10)
  	hud.elements[#hud.elements + 1] = menu
	menu.group = 1

	local panel_builder = require("scripts/hud/panel")
	
	local w, h = sol.video.get_quest_size()

	menu = panel_builder:new(game, "normal")
	menu:set_dst_position(w/2 + -150,-75)
	hud.elements[#hud.elements + 1] = menu
	menu.group = 2

	local menu = panel_builder:new(game, "block")
	menu:set_dst_position(w/2 + -75,-75)
	hud.elements[#hud.elements + 1] = menu
	menu.group = 2

	local menu = panel_builder:new(game, "swordtransform")
	menu:set_dst_position(w/2 + 0,-75)
	hud.elements[#hud.elements + 1] = menu
	menu.group = 2

	local menu = panel_builder:new(game, "special")
	menu:set_dst_position(w/2 + 75,-75)
	hud.elements[#hud.elements + 1] = menu
	menu.group = 2
	
	local menu = person_status_builder:new(game)
	menu:set_dst_position(-10,10)
	local w, h = menu.surface:get_size()
	hud.elements[#hud.elements + 1] = menu
	menu.group = 3
	
	local menu = sword_status_builder:new(game)
	menu:set_dst_position(-10,20+h)
	hud.elements[#hud.elements + 1] = menu
	menu.group = 3
	
	local menu = remaining_status_builder:new(game)
	menu:set_dst_position(-10,30+h*2)
	hud.elements[#hud.elements + 1] = menu
	menu.group = 3
	
	hud.groups = {}
	for i, element in pairs(hud.elements) do
		if element.group ~= nil then
			if hud.groups[element.group] == nil then hud.groups[element.group] = {} end
			hud.groups[element.group][#hud.groups[element.group]+1] = element
		end
	end

	function hud:quit()
		if hud:is_enabled() then
			hud:set_enabled(false)
		end
	end

	function hud:on_map_changed(map)

		if hud:is_enabled() then
			for _, menu in ipairs(hud.elements) do
				if menu.on_map_changed ~= nil then
					menu:on_map_changed(map)
				end
      			end
    		end
  	end

	function hud:on_paused()

   		if hud:is_enabled() then
     			for _, menu in ipairs(hud.elements) do
       				if menu.on_paused ~= nil then
        					  menu:on_paused()
        				end
      			end
    		end
  	end

	function hud:on_unpaused()

		if hud:is_enabled() then
      			for _, menu in ipairs(hud.elements) do
        				if menu.on_unpaused ~= nil then
          					menu:on_unpaused()
        				end
      			end
    		end
  	end

-- Called periodically to change the transparency or position of icons.
  	local function check_hud()
		
    		local map = game:get_map()
    		if map ~= nil then
      			-- If the hero is below the top-left icons, make them semi-transparent.
      			local hero = map:get_entity("hero")
      			local camera_x, camera_y = map:get_camera_position()
      			local hero_x, hero_y = hero:get_position()
      			hero_x = hero_x - camera_x
      			hero_y = hero_y - camera_y
			local screenw, screenh = sol.video.get_quest_size()
			local width, height = screenw, screenh
			
			--check panel
			for groupnum, group in ipairs(hud.groups) do
				local opacity = 255
				for i, element in ipairs(group) do
					local x, y = element.dst_x, element.dst_y
					if x ~= nil then
	  					if x < 0 then
	    						x = width + x
  						end
				  		if y < 0 then
				    			y = height + y
				  		end
						local w, h = element.surface:get_size()
					
					
						if hero_x + 32 > x and hero_x - 32 < x + w and hero_y + 4 > y and hero_y - 60 < y + h then
							opacity = 100
							break
						end
					
--[[
						for entity in map:get_entities("") do
							if entity.entitydata ~= nil then
								local entityx, entityy = entity:get_position()
      								entityx = entityx - camera_x
					      			entityy = entityy - camera_y
								if entityx + 32 > x and entityx - 32 < x + w and entityy + 4 > y and entityy - 60 < y + h then
									opacity = 127
								end
							end
						end
--]]
					end
				end
				
				for i, element in ipairs(group) do
					if element.opacity ~= opacity then
						element.opacity = opacity
						element.surface:set_opacity(opacity)
					end
				end
			end
		end
		return true
	end

	-- Returns whether the HUD is currently enabled.
  	function hud:is_enabled()
    		return hud.enabled
  	end

	-- Enables or disables the HUD.
  	function hud:set_enabled(enabled)

    		if enabled ~= hud.enabled then
      			hud.enabled = enabled

      			for _, menu in ipairs(hud.elements) do
        				if enabled then
          					-- Start each HUD element.
          					sol.menu.start(game, menu)
        				else
          					-- Stop each HUD element.
          					sol.menu.stop(menu)
        				end
      			end

      			if enabled then
        				sol.timer.start(hud, 100, check_hud)
      			end
    		end
  	end

	hud:set_enabled(true)

	return hud
end

return hud_manager

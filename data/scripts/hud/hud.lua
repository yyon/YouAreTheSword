--makes the HUD

local hud_manager = {}

function hud_manager:create(game)
	local hud = {
		enabled = false,
		elements = {},
		showing_dialog = false,
		top_left_opacity = 255,
		custom_command_effects = {},
	}

	local health_builder = require("scripts/hud/health")
	local soul_builder = require("scripts/hud/possess_o_meter")
	local sword_health_builder = require("scripts/hud/sword_health")

	local menu = health_builder:new(game)
  	menu:set_dst_position(0, 10)
  	hud.elements[#hud.elements + 1] = menu

	local menu = soul_builder:new(game)
  	menu:set_dst_position(10, 65)
  	hud.elements[#hud.elements + 1] = menu

	local menu = sword_health_builder:new(game)
  	menu:set_dst_position(10, 10)
  	hud.elements[#hud.elements + 1] = menu

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
      			local hero_x, hero_y = hero:get_position()
      			local camera_x, camera_y = map:get_camera_position()
      			local x = hero_x - camera_x
      			local y = hero_y - camera_y
     			local opacity = nil

      			if hud.top_left_opacity == 255
        				and not game:is_suspended()
        				and x < 88
        				and y < 80 then
        				opacity = 96
      			elseif hud.top_left_opacity == 96
        				and (game:is_suspended()
        				or x >= 88
        				or y >= 80) then
        				opacity = 255
      			end

      			if opacity ~= nil then
        				hud.top_left_opacity = opacity
--        				hud.item_icon_1.surface:set_opacity(opacity)
--        				hud.item_icon_2.surface:set_opacity(opacity)
--        				hud.pause_icon.surface:set_opacity(opacity)
--        				hud.attack_icon.surface:set_opacity(opacity)
--        				hud.action_icon.surface:set_opacity(opacity)
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
        				sol.timer.start(hud, 50, check_hud)
      			end
    		end
  	end

	hud:set_enabled(true)

	return hud
end

return hud_manager
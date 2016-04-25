-- This is the main Lua script of your project.
-- You will probably make a title screen and then start a game.
-- See the Lua API! http://www.solarus-games.org/solarus/documentation/

local game_manager = require("scripts/game_manager")
keyhandler = function() print("Error: unhandled key press") end
mousehandler = function() print("Error: unhandled key press") end
local main_menu
local main_menu_file = require "menus/main_menu"

function sol.main:on_started()
	-- This function is called when Solarus starts.
	print("This is a sample quest for Solarus.")

	local width, height = sol.video.get_quest_size()
	sol.video.set_fullscreen(false)
	sol.video.set_mode("normal")
	sol.video.set_window_size(width, height)

	-- Setting a language is useful to display text and dialogs.
	sol.language.set_language("en")

	-- Show the Solarus logo initially.
	local solarus_logo = require("menus/solarus_logo")
	local title_screen = require("menus/title")
	sol.menu.start(self, solarus_logo)

	solarus_logo.on_finished = function()
		if self.game == nil then
			sol.menu.start(self, title_screen)
			--game_manager:start_game()
		end
	end

	title_screen.startmain = function(title)
		configload()
		main_menu = main_menu_file:new(self, title)
		sol.menu.start(self, main_menu)
		--game_manager:start_game()
	end


	-- Start the game when the Solarus logo menu is finished.
--	solarus_logo.on_finished = function()

--	end

end

function sol.main:on_finished()
end

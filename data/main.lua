-- This is the main Lua script of your project.
-- You will probably make a title screen and then start a game.
-- See the Lua API! http://www.solarus-games.org/solarus/documentation/

local game_manager = require("scripts/game_manager")


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

	title_screen.on_finished = function()
		game_manager:start_game()
	end

	-- Start the game when the Solarus logo menu is finished.
--	solarus_logo.on_finished = function()

--	end

end

function sol.main:on_finished()
end

local pause_manager = {}

function pause_manager:create(game) 
	local pause_menu = {}
	game.pause_menu = pause_menu

	function pause_menu:on_started()

		game.pause_submenus = {
		--replace with submenus when built
		}

		sol.audio.play_sound("pause_open")

	end

	function pause_menu:on_finished()

		sol.audio.play_sound("pause_closed")

		game.pause_submenus = {}

	end
	return pause_menu
end

return pause_manager
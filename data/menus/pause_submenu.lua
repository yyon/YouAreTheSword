local submenu = {}

function submenu:new(game)
	local o = {game = game}
	setmetatable(o, self)
	self.__index = self
	return o
end

function submenu:on_started()
	self.background_surfaces = sol.surface.create("pause_submenus.png", true)
	self.background_surfaces:set_opacity(216)
	self.save_dialog_sprite = sol.sprite.create("menus/pause_save_dialog")
	self.save_dialog_state = 0

	local dialog_font, dialog_font_size = "8_bit_3", 12

	self.question_text_1 = sol.text_surface.create {
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		color = {8, 8, 8},
		font = dialog_font,
		font_size = dialog_font_size,
	}
	self.question_text_2 = sol.text_surface.create {
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		color = {8, 8, 8},
		font = dialog_font,
		font_size = dialog_font_size,
	}
	self.answer_text_1 = sol.text_surface.create {
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		color = {8, 8, 8},
		text_key = "save_dialog.yes",
		font = dialog_font,
		font_size = dialog_font_size,
	}
	self.answer_text_2 = sol.text_surface.create {
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		color = {8, 8, 8},
		text_key = "save_dialog.no",
		font = dialog_font,
		font_size = dialog_font_size,
	}
	self.caption_text_1 = sol.text_surface.create {
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		font = dialog_font,
		font_size = dialog_font_size,
	}
	self.caption_text_2 = sol.text_surface.create {
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		font = dialog_font,
		font_size = dialog_font_size,
	}

	self.game:set_custom_command_effect("action", nil)
	self.game:set_custom_command_effect("attack", "save")
end


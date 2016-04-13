local class = require "middleclass"

local submenu = class("submenu")

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

function submenu:set_caption(text_key)
	if text_key == nil then
		self.caption_text_1:set_text(nil)
		self.caption_text_2:set_text(nil)
	else
		local text = sol.language.get_string(text_key)
		if text == nil then
			self.caption_text_1:set_text(nil)
			self.caption_text_2:set_text(nil)
			return
		end
		local line1, line2 = text:match("([^$]+)%$(.*)")
		if line1 == nil then
			self.caption_text_1:set_text(text)
			self.caption_text_2:set_text(nil)
		else
			self.caption_text_1:set_text(line1)
			self.caption_text_2:set_text(line2)
		end
	end
end

function submenu:draw_caption(dst_surface)
	local width, height = dst_surface:get_size()
	if self.caption_text_2:get_text():len() == 0 then
		self.caption_text_1:draw(dst_surface, width / 2, height / 2 + 89)
	else
		self.caption_text_1:draw(dst_surface, width / 2, height /2  + 83)
		self.caption_text_2:draw(dst_surface, width / 2, height / 2 + 95)
	end
end

function submenu:on_command_pressed(command)
	local handled = false
	if self.game:is_dialog_enabled() then
		return false
	end

	if self.save_dialog_state == 0 then

	else
		if command ~= "pause" then
			handled = true
		end
		if command == "left" or command == "right" then
			if self.save_dialog_choice == 0 then
				self.save_dialog_choice = 1
				self.save_dialog_sprite:set_animation("right")
			else
				self.save_dialog_choice = 0
				self.save_dialog_sprite:set_animation("left")
			end
		elseif command == "action" or command == "attack" then
			if self.save_dialog_state == 1 then
				-- Do you want to save?
				self.save_dialog_state = 2
				if self.save_dialog_choice == 0 then
					self.game:save()
				end
				self.question_text_1:set_text_key("save_dialog.continue_question_0")
					self.question_text_2:set_text_key("save_dialog.continue_question_1")
				self.save_dialog_choice = 0
				self.save_dialog_sprite:set_animation("left")
			else
				self.save_dialog_state = 0
			end
		end
	end
	return handled
end

function submenu:draw_background(dst_surface)
	local submenu_index = self.game:get_value("pause_last_submenu")
	local width, height = dst_surface:get_size()
	self.background_surfaces:draw_region(1280 * (submenu_index - 1), 0, 1280, 720, dst_surface, (width - 1280) / 2, (height - 720) / 2)
end

function submenu:draw_save_dialog_if_any(dst_surface)
	if self.save_dialog_state > 0 then
		local width, height = dst_surface:get_size()
		local x = width / 2
		local y = height / 2
		self.save_dialog_sprite:draw(dst_surface, x - 110, y - 33)
		self.question_text_1:draw(dst_surface, x, y - 8)
		self.question_text_2:draw(dst_surface, x, y + 8)
		self.answer_text_1:draw(dst_surface, x - 60, y + 28)
		self.answer_text_2:draw(dst_surface, x + 59, y + 28)
	end
end
return submenu

local title_screen = {}

function title_screen:on_started()
	keyhandler = function(...) self:on_key_pressed(...) end

	self.phase = "black"

	self.surface = sol.surface.create(1280,900)
	sol.timer.start(self, 300, function()
		self:phase_the_team_presents()
	end)

end

function title_screen:phase_the_team_presents()
	self.phase = "the_team_presents"

	self.the_team_presents_img = sol.surface.create("title_screen_initilization.png", true)

	local width, height = self.the_team_presents_img:get_size()
	self.the_team_presents_pos = {1280/2 - width / 2, 900/2 - height / 2}

	self.presentstimer = sol.timer.start(self, 2000, function()
		self.surface:fade_out(10)
		sol.timer.start(self, 700, function()
			self:phase_title()
		end)
	end)
end

function title_screen:phase_title()

	self.phase = "title"

	self.background_img = sol.surface.create("menus/title_daylight_background2.png")
	self.clouds_img = sol.surface.create("menus/title_daylight_clouds2.png")
	self.logo = sol.surface.create("menus/logo_title.png")
	self.borders_img = sol.surface.create("menus/title_borders2.png")

	local dialog_font, dialog_font_size = "8_bit_3", 12
	local menu_font, menu_font_size = "8_bit_3", 12

	self.press_space_img = sol.text_surface.create{
		font = dialog_font,
		font_size = dialog_font_size,
		color = {255, 255, 255},
		text_key = "title_screen.press_space",
		horizontal_alignment = "center"
	}


	self.show_press_space = false
	function switch_press_space()
		self.show_press_space = not self.show_press_space
		sol.timer.start(self, 500, switch_press_space)
	end
	sol.timer.start(self, 6500, switch_press_space)


	self.clouds_xy = {x = 1280, y = 720}
	function move_clouds()
		self.clouds_xy.x = self.clouds_xy.x + 1
		self.clouds_xy.y = self.clouds_xy.y - 1
		if self.clouds_xy.x >= 2140 then
			self.clouds_xy.x = self.clouds_xy.x - 2140
		end
		if self.clouds_xy.y >= 2140 then
			self.clouds_xy.y = self.clouds_xy.y + 1193
		end
		sol.timer.start(self, 50, move_clouds)
	end
	sol.timer.start(self, 50, move_clouds)

	self.surface:fade_in(30)

	self.allow_skip = false
	sol.timer.start(self, 2000, function()
		self.allow_skip = true
	end)
end

function title_screen:on_draw(dst_surface)
	if self.phase == "title" then
		self:draw_phase_title(dst_surface)
	elseif self.phase == "the_team_presents" then
		self:draw_phase_present()
	end

	local width, height = dst_surface:get_size()
	self.surface:draw(dst_surface, width/2 - 1280/2, height/2 - 900/2)
end

function title_screen:draw_phase_present()

	self.the_team_presents_img:draw(self.surface, self.the_team_presents_pos[1], self.the_team_presents_pos[2])

end

function title_screen:draw_phase_title()

	self.surface:fill_color({0, 0, 0})
	self.background_img:draw(self.surface)

	local x, y = self.clouds_xy.x, self.clouds_xy.y
	self.clouds_img:draw(self.surface, x, y)
	x = self.clouds_xy.x - 2140
	self.clouds_img:draw(self.surface, x, y)
	x = self.clouds_xy.x
	y = self.clouds_xy.y - 1192
	self.clouds_img:draw(self.surface, x, y)
	x = self.clouds_xy.x - 2140
	y = self.clouds_xy.y - 1192
	self.clouds_img:draw(self.surface, x, y)

	self.borders_img:draw(self.surface, 0, 0)

	self.logo:draw(self.surface, 1280/2 - 746/2, 720/2 - 306/2)

	if self.show_press_space then
		self.press_space_img:draw(self.surface, 1280/2, 780)
	end
end

function title_screen:on_key_pressed(key)
	local handled = false

	if key == "escape" then
		sol.main.exit()
		handled = true
	elseif key == "space" or key == "return" then
		handled = self:try_finish_title()

	end
end

function title_screen:try_finish_title()
	local handled = false
	if self.phase == "title" then
		self.finished = true
		self.surface:fade_out(30)
		sol.timer.start(self, 700, function()
			self:finish_title()
		end)

		handled = true
	elseif self.phase == "the_team_presents" then
		self.presentstimer:stop()
		sol.timer.start(self, 100, function()
			self:phase_title()
		end)
	end
	return handled
end

function title_screen:finish_title()
	sol.menu.stop(self)
end

return title_screen

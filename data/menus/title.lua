local title_screen = {}

function title_screen:on_started()
	self.phase = "black"

	self.surface = sol.surface.create(320,240)
	sol.timer.start(self, 300, function()
		self:phase_the_team_presents()
	end)

end

function title_screen:phase_the_team_presents()
	self.phase = "the_team_presents"

	self.the_team_presents_img = sol.surface.create("title_screen_initilization.png", true)

	local width, height = self.the_team_presents_img:get_size()
	self.the_team_presents_pos = {160 - width / 2, 120 - height / 2}

	sol.timer.start(self, 2000, function()
		self.surface:fade_out(10)
		sol.timer.start(self, 700, function()
			self:phase_title()
		end)
	end)
end

function title_screen:phase_title()

	self.phase = "title"
	
	self.background_img = sol.surface.create("menus/title_daylight_background.png")
	self.clouds_img = sol.surface.create("menus/title_daylight_clouds.png")
	--add the logo once it's drawn
	self.borders_img = sol.surface.create("menus/title_borders.png")

	local dialog_font, dialog_font_size = sol.language.get_dialog_font()
	local menu_font, menu_font_size = sol.language.get_menu_font()

	self.press_space_img = sol.text_surface.create{
		font = dialog_font,
		font_size = dialog_font_size,
		color = {255, 255, 255},
		text_key = "title_screen.press_space",
		horizontal_alignment = "center"
	}

	print("HERE")

	self.show_press_space = false
	function switch_press_space()
		self.show_press_space = not self.show_press_space
		sol.timer.start(self, 500, switch_press_space)
	end
	sol.timer.start(self, 6500, switch_press_space)

	print("here also")

	self.clouds_xy = {x = 320, y = 240}
	function move_clouds()
		self.clouds_xy.x = self.clouds_xy.x + 1
		self.clouds_xy.y = self.clouds_xy.y - 1
		if self.clouds_xy.x >= 535 then
			self.clouds_xy.x = self.clouds_xy.x - 535
		end
		if self.clouds_xy.y >= 535 then
			self.clouds_xy.y = self.clouds_xy.y + 299
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
	self.surface:draw(dst_surface, width/2 - 160, height/2 - 120)
end

function title_screen:draw_phase_present()

	self.the_team_presents_img:draw(self.surface, self.the_team_presents_pos[1], self.the_team_presents_pos[2])

end

function title_screen:draw_phase_title()
	
	self.surface:fill_color({0, 0, 0})
	self.background_img:draw(self.surface)

	local x, y = self.clouds_xy.x, self.clouds_xy.y
	self.clouds_img:draw(self.surface, x, y)
	x = self.clouds_xy.x - 535
	self.clouds_img:draw(self.surface, x, y)
	x = self.clouds_xy.x
	y = self.clouds_xy.y - 299
	self.clouds_img:draw(self.surface, x, y)
	x = self.clouds_xy.x - 535
	y = self.clouds_xy.y - 299
	self.clouds_img:draw(self.surface, x, y)
	
	self.borders_img:draw(self.surface, 0, 0)

	--draw logo

	if self.show_press_space then
		self.press_space_img:draw(self.surface, 160, 200)
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
	if self.phase == "title"
		and self.allow_skip
		and not self.finished then
		self.finished = true
		self.surface:fade_out(30)
		sol.timer.start(self, 700, function()
			self:finish_title()
		end)

		handled = true
	end
	return handled
end

function title_screen:finish_title()
	sol.menu.stop(self)
end

return title_screen























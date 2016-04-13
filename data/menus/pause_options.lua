local submenu = require("menus/pause_submenu")

local main_submenu = submenu:new()

function main_submenu:on_started()
  submenu.on_started(self)

  local font, font_size = "8_bit_3", 12
  local width, height = sol.video.get_quest_size()
  local center_x, center_y = width / 2, height / 2

  self.resume_button_text = sol.text_surface.create {
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "selection_menu.main.resume",
  }
  self.resume_button_text:set_xy(center_x - 50, center_y)

  self.save_button_text = sol.text_surface.create {
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "selection_menu.main.save",
  }
  self.save_button_text:set_xy(center_x - 100, center_y)

  self.load_button_text = sol.text_surface.create {
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "selection_menu.main.load",
  }
  self.load_button_text:set_xy(center_x - 150, center_y)


  self.options_button_text = sol.text_surface.create {
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "selection_menu.main.options",
  }
  self.options_button_text:set_xy(center_x - 200, center_y)


  self.quit_button_text = sol.text_surface.create {
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "selection_menu.main.quit",
  }
  self.quit_button_text:set_xy(center_x - 250, center_y)

end

function main_submenu:on_draw(dst_surface)
  self:draw_background(dst_surface)
  self:draw_caption(dst_surface)

  self.resume_button_text:draw(dst_surface)
  self.save_button_text:draw(dst_surface)
  self.load_button_text:draw(dst_surface)
  self.options_button_text:draw(dst_surface)
  self.quit_button_text:draw(dst_surface)

end

return main_submenu

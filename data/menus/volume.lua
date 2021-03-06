local class = require("middleclass")
local confirmation = require("menus/confirmation")

require "scripts/inputhandler"

local math = require "math"

local lineify = require("menus/lineify")
local createbox = require "menus/drawbox"

local dialog = class("dialog")

function dialog:initialize(game)
  inputhandler:new(self)

  self.game = game
  local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
	self.w, self.h = self.screenw, self.screenh
	center_x, center_y = w/2, h/2
  self.surface = sol.surface.create(self.w, self.h)
	local y = center_y

  self.buttons = {}

  self.buttons.sound_button = menubutton(self, center_x - 205, y, 400, 60, "Sound Volume: " .. conf.sound, function() self:rebuild_surface() end)
y = y + 70
self.buttons.sound_up_button = menubutton(self, center_x - 205, y, 400, 60, "Sound Volume +", function() self:sound_up() end)
  y = y + 70
  self.buttons.sound_down_button = menubutton(self, center_x - 205, y, 400, 60, "Sound Volume -", function() self:sound_down() end)
  y = y - 140
  self.buttons.music_button = menubutton(self, center_x + 205, y, 400, 60, "Music Volume: " .. conf.music, function() self:rebuild_surface() end)
y = y + 70
  self.buttons.music_up_button = menubutton(self, center_x + 205, y, 400, 60, "Music Volume +", function() self:music_up() end)
  y = y + 70
  self.buttons.music_down_button = menubutton(self, center_x + 205, y, 400, 60, "Music Volume -", function() self:music_down() end)
  y = y + 70
  self.buttons.exit_button = menubutton(self, center_x, y, 400, 60, "Exit", function() self:finish() end)

end

function dialog:sound_up()
  if conf.sound ~= 100 then
    conf.sound = conf.sound + 10
  end
  configsave()
	updatevolume()
self.buttons.sound_button.text = "Sound Volume: " .. conf.sound
self.buttons.sound_button:rebuild()
self:rebuild_surface()
end

function dialog:sound_down()
  if conf.sound ~= 0 then
    conf.sound = conf.sound - 10
  end
  configsave()
	updatevolume()
self.buttons.sound_button.text = "Sound Volume: " .. conf.sound
self.buttons.sound_button:rebuild()
self:rebuild_surface()
end

function dialog:music_up()
  if conf.music ~= 100 then
    conf.music = conf.music + 10
  end
  configsave()
	updatevolume()
self.buttons.music_button.text = "Music Volume: " .. conf.music
self.buttons.music_button:rebuild()
self:rebuild_surface()
end

function dialog:music_down()
  if conf.music ~= 0 then
    conf.music = conf.music - 10
  end
  configsave()
	updatevolume()
self.buttons.music_button.text = "Music Volume: " .. conf.music
self.buttons.music_button:rebuild()
self:rebuild_surface()
end

function dialog:on_started()
  	self:check()
end

function dialog:check()
  	self:rebuild_surface()
  	sol.timer.start(self, 500, function()
    		self:check()
  	end)
end

function dialog:rebuild_surface()
	self.surface:clear()
	for _, button in pairs(self.buttons) do
		button:draw(self.surface)
	end
end

function dialog:on_draw(dst_surface)
	self.surface:draw(dst_surface, self.dst_x, self.dst_y)
end

function dialog:finish()
  sol.menu.stop(self)
end


return dialog

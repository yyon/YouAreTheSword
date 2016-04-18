local class = require("middleclass")

local dialog = class("dialog")

local entitydata = require "enemies/entitydata"

local math = require "math"

local lineify = require "menus/lineify"

function dialog:initialize(game)
	local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
  	self.game = game
	self.w, self.h = 1100, 220
  	self.surface = sol.surface.create(self.w, self.h)
	self.dialogsurface = sol.surface.create("hud/dialog.png")
	self.stage = 0
	self.type = type
	self.texts = {}
--	game.dialog = self
end

function dialog:on_started()
	self.danger_sound_timer = nil
  	self:check(nil)
  	self:rebuild_surface()
end

--  check heart data and fix periodically
function dialog:check()
--	self:rebuild_surface()
 	-- check again in 50ms
--  	sol.timer.start(self, 500, function()
--    		self:check()
--  	end)
end

function dialog:ondialog(dialog, endfunct)
    self.text = dialog.text
    self.screennum = 1
    self.lines = lineify.tolines(self.text, 50)
    self.screens = lineify.toscreens(self.lines, 6)

    self.endfunct = endfunct
    self.isshowingdialog = true

    self:showscreen()
end

function dialog:finish()
        self.isshowingdialog = false
        game:stop_dialog()
end

function dialog:showscreen()
    if self.screennum > #self.screens then
	self:finish()
    else
        self.screentext = self.screens[self.screennum]
--        self:rebuild_surface()
        self.screennum = self.screennum + 1
        self:rebuild_surface()
    end
end

function dialog:rebuild_surface()
    self.surface:clear()

    if self.isshowingdialog then
          self.dialogsurface:draw_region(0, 0, self.w, self.h, self.surface, 0, 0)
          lineify.rendertext(self.surface, self.screentext, "LiberationMono-Regular", 25, {255,255,255}, true, 115, 15)
  end
end

function dialog:on_draw(dst_surface)
  	local x, y = 0, 0
  	local width, height = dst_surface:get_size()
	x = self.screenw / 2 - self.w / 2
	y = self.screenh - self.h - 20
	self.surface:draw(dst_surface, x, y)
end

return dialog

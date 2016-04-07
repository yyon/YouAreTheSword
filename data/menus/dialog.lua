local class = require("middleclass")

local dialog = class("dialog")

local entitydata = require "enemies/entitydata"

local math = require "math"

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
	self:rebuild_surface()
  	-- check again in 50ms
  	sol.timer.start(self, 50, function()
    		self:check()
  	end)
end

function dialog:mysplit(inputstr, sep)
    return string.gmatch(inputstr, "([^"..sep.."]+)")
end

function dialog:ondialog(dialog, endfunct)
    self.text = dialog.text
    self.screens = {}
    self.screennum = 1
    local linenum = 0
    local currentstring = ""
    function addline(line)
        if linenum >= 7 or line == "NEWSCREEN" then
            linenum = 0
            self.screens[#self.screens+1] = currentstring
            currentstring = ""
        end
        if line ~= "NEWSCREEN" then
            currentstring = currentstring .. line .. "\n"
            linenum = linenum + 1
        end
    end
    for line in self:mysplit(self.text, "\n") do
        local curlen = 0
        local currentline = ""
        local firstword = true
        for word in self:mysplit(line, " ") do
            local strlen = string.len(word)
            if firstword then
                firstword = false
                currentline = word
                curlen = strlen
            else
                if curlen + strlen + 1 > 50 then
                    addline(currentline)
                    currentline = word
                    curlen = strlen
                else
                    currentline = currentline .. " " .. word
                    curlen = curlen + 1 + strlen
                end
            end
        end
        addline(currentline)
    end
    self.screens[#self.screens+1] = currentstring

    self.endfunct = endfunct
    self.isshowingdialog = true

    self:showscreen()
end

function dialog:showscreen()
    if self.screennum > #self.screens then
        self.isshowingdialog = false
        game:stop_dialog()
    else
        self.screentext = self.screens[self.screennum]
        self:rebuild_surface()
        self.screennum = self.screennum + 1
    end
end

function dialog:rebuild_surface()
    self.surface:clear()

    local x = 115
    local y = 15

    if self.isshowingdialog then
        self.dialogsurface:draw_region(0, 0, self.w, self.h, self.surface, 0, 0)

        for line in self:mysplit(self.screentext, "\n") do
            local text = sol.text_surface.create({horizontal_alignement="left", vertical_alignement="bottom", text=line, font="8_bit_3"})
            local w, h = text:get_size()
            y = y + h/2
            text:draw_region(0, 0, w, h, self.surface, x, y)
            y = y + h/2
        end
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

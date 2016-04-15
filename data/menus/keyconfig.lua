local class = require("middleclass")

require "scripts/inputhandler"

local math = require "math"

local lineify = require("menus/lineify")
local createbox = require "menus/drawbox"

local dialog = class("dialog")

local keylistener = class("keylistener")

function dialog:initialize(game)
	inputhandler:new(self)

	local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
  	self.game = game
	self.w, self.h = self.screenw, self.screenh
  	self.surface = sol.surface.create(self.w, self.h)
	
	local h = 40
	
	local y = 40
	self.labels = {}
	self.buttons = {}
	self.labels.up = boxsprite(w/2 - 355, y, 400, h, false, false, "Up:")
	self.buttons.upbutton1 = menubutton(self, w/2, y, 300, h, "", function() self:config("upbutton1") end)
	self.buttons.upbutton1.key = {"up", 1}
	y = y + h + 10
	self.labels.down = boxsprite(w/2 - 355, y, 400, h, false, false, "Down:")
	self.buttons.downbutton1 = menubutton(self, w/2, y, 300, h, "", function() self:config("downbutton1") end)
	self.buttons.downbutton1.key = {"down", 1}
	y = y + h + 10
	self.labels.left = boxsprite(w/2 - 355, y, 400, h, false, false, "Left:")
	self.buttons.leftbutton1 = menubutton(self, w/2, y, 300, h, "", function() self:config("leftbutton1") end)
	self.buttons.leftbutton1.key = {"left", 1}
	y = y + h + 10
	self.labels.right = boxsprite(w/2 - 355, y, 400, h, false, false, "Right:")
	self.buttons.rightbutton1 = menubutton(self, w/2, y, 300, h, "", function() self:config("rightbutton1") end)
	self.buttons.rightbutton1.key = {"right", 1}
	y = y + h + 10
	self.labels.normal = boxsprite(w/2 - 355, y, 400, h, false, false, "Normal Ability:")
	self.buttons.normal1 = menubutton(self, w/2, y, 300, h, "", function() self:config("normal1") end)
	self.buttons.normal1.key = {"normal", 1}
	self.buttons.normal2 = menubutton(self, w/2 + 305, y, 300, h, "", function() self:config("normal2") end)
	self.buttons.normal2.key = {"normal", 2}
	y = y + h + 10
	self.labels.block = boxsprite(w/2 - 355, y, 400, h, false, false, "Block Ability:")
	self.buttons.block1 = menubutton(self, w/2, y, 300, h, "", function() self:config("block1") end)
	self.buttons.block1.key = {"block", 1}
	self.buttons.block2 = menubutton(self, w/2 + 305, y, 300, h, "", function() self:config("block2") end)
	self.buttons.block2.key = {"block", 2}
	y = y + h + 10
	self.labels.swt = boxsprite(w/2 - 355, y, 400, h, false, false, "Sword Transform Ability:")
	self.buttons.swtbutton1 = menubutton(self, w/2, y, 300, h, "", function() self:config("swtbutton1") end)
	self.buttons.swtbutton1.key = {"swordtransform", 1}
	self.buttons.swtbutton2 = menubutton(self, w/2 + 305, y, 300, h, "", function() self:config("swtbutton2") end)
	self.buttons.swtbutton2.key = {"swordtransform", 2}
	y = y + h + 10
	self.labels.special = boxsprite(w/2 - 355, y, 400, h, false, false, "Special Ability:")
	self.buttons.special1 = menubutton(self, w/2, y, 300, h, "", function() self:config("special1") end)
	self.buttons.special1.key = {"special", 1}
	self.buttons.special2 = menubutton(self, w/2 + 305, y, 300, h, "", function() self:config("special2") end)
	self.buttons.special2.key = {"special", 2}
	y = y + h + 10
	self.labels.throwallies = boxsprite(w/2 - 355, y, 400, h, false, false, "Throw Sword To Allies:")
	self.buttons.throwallies1 = menubutton(self, w/2, y, 300, h, "", function() self:config("throwallies1") end)
	self.buttons.throwallies1.key = {"throwallies", 1}
	self.buttons.throwallies2 = menubutton(self, w/2 + 305, y, 300, h, "", function() self:config("throwallies2") end)
	self.buttons.throwallies2.key = {"throwallies", 2}
	y = y + h + 10
	self.labels.throwenemies = boxsprite(w/2 - 355, y, 400, h, false, false, "Throw Sword To Enemies:")
	self.buttons.throwenemies1 = menubutton(self, w/2, y, 300, h, "", function() self:config("throwenemies1") end)
	self.buttons.throwenemies1.key = {"throwenemies", 1}
	self.buttons.throwenemies2 = menubutton(self, w/2 + 305, y, 300, h, "", function() self:config("throwenemies2") end)
	self.buttons.throwenemies2.key = {"throwenemies", 2}
	y = y + h + 10
	self.labels.throwany = boxsprite(w/2 - 355, y, 400, h, false, false, "Throw Sword To Anyone:")
	self.buttons.throwany1 = menubutton(self, w/2, y, 300, h, "", function() self:config("throwany1") end)
	self.buttons.throwany1.key = {"throwany", 1}
	self.buttons.throwany2 = menubutton(self, w/2 + 305, y, 300, h, "", function() self:config("throwany2") end)
	self.buttons.throwany2.key = {"throwany", 2}
	y = y + h + 10
	self.labels.abilityhelp = boxsprite(w/2 - 355, y, 400, h, false, false, "Ability Help:")
	self.buttons.abilityhelp1 = menubutton(self, w/2, y, 300, h, "", function() self:config("abilityhelp1") end)
	self.buttons.abilityhelp1.key = {"abilityhelp", 1}
	self.buttons.abilityhelp2 = menubutton(self, w/2 + 305, y, 300, h, "", function() self:config("abilityhelp2") end)
	self.buttons.abilityhelp2.key = {"abilityhelp", 2}
	y = y + h + 10
	self.labels.pause = boxsprite(w/2 - 355, y, 400, h, false, false, "Pause:")
	self.buttons.pausebutton1 = menubutton(self, w/2, y, 300, h, "", function() self:config("pausebutton1") end)
	self.buttons.pausebutton1.key = {"pause", 1}
	self.buttons.pausebutton2 = menubutton(self, w/2 + 305, y, 300, h, "", function() self:config("pausebutton2") end)
	self.buttons.pausebutton2.key = {"pause", 2}
	y = y + h + 10
	self.buttons.exitbutton = menubutton(self, w/2, y, 600, h, "exit", function() self:finish() end)
	
	self:refresh()
end

function dialog:refresh()
	for _, button in pairs(self.buttons) do
		if button.key ~= nil then
			local key, num = button.key[1], button.key[2]
			local setto = conf.keys[key][num]
			if setto == nil then
				setto = ""
			end
			button.text = setto
			button:rebuild()
		end
	end
	
	self:rebuild_surface()
end

function dialog:config(button)
	local b = self.buttons[button]
	local key, num = b.key[1], b.key[2]
	local keylistenermenu = keylistener:new(game, self, key, num)
	sol.menu.start(game, keylistenermenu)
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
	for _, label in pairs(self.labels) do
		label:draw(self.surface)
	end
	for _, button in pairs(self.buttons) do
		button:draw(self.surface)
	end
end

function dialog:on_draw(dst_surface)
	self.surface:draw(dst_surface, self.dst_x, self.dst_y)
end

function dialog:finish()
	game.dontshowpausemenu = false
	game:set_paused(false)
	sol.menu.stop(self)
end

function keylistener:initialize(game, parentmenu, type, num)
	inputhandler:new(self)

	self.parentmenu = parentmenu
	self.type = type
	self.num = num

	local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
  	self.game = game
	self.w, self.h = self.screenw, self.screenh
  	self.surface = sol.surface.create(self.w, self.h)

	self.box = createbox(800, 600, true, false)
	lineify.rendertext(self.box, "Press key or mouse button\nPress delete to clear", "LiberationMono-Regular", 25, {255,255,255}, true, 400, 300, true, true)

	print "Key listener"
end

function keylistener:on_started()
  	self:check()
end

function keylistener:check()
  	self:rebuild_surface()
  	sol.timer.start(self, 500, function()
    		self:check()
  	end)
end

function keylistener:rebuild_surface()
	self.surface:clear()
	self.box:draw(self.surface, self.screenw/2 - 400, self.screenh/2 - 300)
end

function keylistener:on_draw(dst_surface)
	self.surface:draw(dst_surface, self.dst_x, self.dst_y)
end

function keylistener:onkey(key)
	self:finish(key)
end
function keylistener:onmouse(button)
	button = button .. "_mouse"
	self:finish(button)
end

function keylistener:finish(key)
	if key == "delete" then
		print("DELETE")
		key = nil
	end
	print(self.type, self.num, key)
	conf.keys[self.type][self.num] = key
	sol.menu.stop(self)
	self.parentmenu:refresh()
	updatekeys()
	configsave()
end


return dialog

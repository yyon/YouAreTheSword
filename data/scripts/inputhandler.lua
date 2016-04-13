local class = require "middleclass"

inputhandler = class("inputhandler")

local createbox = require "menus/drawbox"

local lineify = require("menus/lineify")

function inputhandler:initialize(menu)
	self.menu = menu

	self.buttons = {}

	self.oldonremoved = menu.on_finished
	function self.menu.on_finished(menu)
		self:on_removed()
		if self.oldonremoved ~= nil then
			self.oldonremoved(menu)
		end
	end

	self.oldkeyhandler = keyhandler
	self.oldmousehandler = mousehandler

	keyhandler = function(...) self:on_key_pressed(...) end
	mousehandler = function(...) self:on_mouse_pressed(...) end

	self.menu.theinputhandler = self
end

function inputhandler:on_removed()
	keyhandler = self.oldkeyhandler
	mousehandler = self.oldmousehandler
end

function inputhandler:on_key_pressed(key, ...)
	if self.menu.onkey ~= nil then
		self.menu:onkey(key, ...)
	end
end

function inputhandler:on_mouse_pressed(...)
	local mousex, mousey = sol.input.get_mouse_position()

	local foundbutton = false
	for button, _ in pairs(self.buttons) do
		if mousex > button.x - button.w/2 and mousey > button.y - button.h/2 and mousex < button.x + button.w/2 and mousey < button.y + button.h/2 then
			foundbutton = true
			button:click()
			break
		end
	end

	if not foundbutton then
		if self.menu.onmouse ~= nil then
			self.menu:onmouse(...)
		end
	end
end

menubutton = class("menubutton")

function menubutton:initialize(menu, x, y, w, h, text, funct)
	self.menu = menu
	self.funct = funct
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.text = text

  	self.surface = sol.surface.create(self.w, self.h)
	self.buttonimg = createbox(self.w, self.h, false, true)--sol.surface.create("menus/button.png")

	menu.theinputhandler.buttons[self] = true

	self:rebuild()
end

function menubutton:rebuild()
	self.surface:clear()

	self.buttonimg:draw(self.surface, 0, 0)
	lineify.rendertext(self.surface, self.text, "LiberationMono-Regular", 25, {255,255,255}, true, self.w/2, self.h/2, true, true)
end

function menubutton:draw(surface)
	self.surface:draw(surface, self.x - self.w/2, self.y - self.h/2)
end

function menubutton:click()
	if self.funct ~= nil then
		self.funct()
	end
end

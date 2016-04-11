local class = require "middleclass"

inputhandler = class("inputhandler")

local lineify = require("menus/lineify")

function inputhandler:initialize(menu)
	self.menu = menu
	
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

function inputhandler:on_key_pressed(...)
	if self.menu.on_key_pressed ~= nil then
		self.menu:on_key_pressed(...)
	end
end

function inputhandler:on_mouse_pressed(...)
	local mousex, mousey = sol.input.get_mouse_position()
	if self.menu.on_mouse_pressed ~= nil then
		self.menu:on_mouse_press5ed(...)
	end
end

menubutton = class("menubutton")

function menubutton:initialize(menu, x, y, text, funct)
	self.menu = menu
	self.funct = funct
	self.x = x
	self.y = y
	self.text = text
	
  	self.surface = sol.surface.create(600, 60)
	self.buttonimg = sol.surface.create("menus/button.png")
	
	self:rebuild()
end

function menubutton:rebuild()
	self.surface:clear()
	
	self.buttonimg:draw(self.surface, 0, 0)
	lineify.rendertext(self.surface, self.text, "LiberationMono-Regular", 25, {255,255,255}, true, 300, 30, true, true)
end

function menubutton:draw(surface)
	self.surface.draw(surface, self.x - 300, self.y - 30)
end


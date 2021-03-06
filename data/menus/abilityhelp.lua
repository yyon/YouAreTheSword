local class = require("middleclass")

local dialog = class("dialog")

local entitydata = require "enemies/entitydata"

local math = require "math"

local lineify = require "menus/lineify"

function dialog:initialize(game)
	local w, h = sol.video.get_quest_size()
	self.screenw, self.screenh = w, h
  	self.game = game
	self.w, self.h = self.screenw, self.screenh
  	self.surface = sol.surface.create(self.w, self.h)
	self.types = {"normal", "block", "swordtransform", "special"}
	self.typenames = {"Normal Ability", "Block Ability", "Sword Transform Ability", "Special Ability"}
	local hero = self.game:get_hero().entitydata
	if hero ~= nil then
		self:rebuild_surface()
	end
end

function dialog:on_started()
  	self:rebuild_surface()
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

function dialog:showscreen()
    if self.screennum > #self.screens then
        self.isshowingdialog = false
        game:stop_dialog()
    else
        self.screentext = self.screens[self.screennum]
--        self:rebuild_surface()
        self.screennum = self.screennum + 1
        self:rebuild_surface()
    end
end

function dialog:rebuild_surface()
	self.surface:clear()
	
	local hero = self.game:get_map():get_hero().entitydata
	for i, type in pairs(self.types) do
		local abilitysurface = sol.surface.create(self.w / 4, self.h)
		
		local ability = hero:getability(type)
		local icon = ability.icon
		
		local back = sol.surface.create("menus/abilityhelp.png")
	          back:draw(abilitysurface, 0, 0)
	
		local icon = sol.surface.create("icons_smaller/" .. icon .. ".png")
	          icon:draw(abilitysurface, 126, 67)
	
	          lineify.rendertext(abilitysurface, ability.name, "LiberationMono-Bold", 25, {255,100,100}, true, self.w / 8, 200, true)
		
		local descy = 250
		local stats = ability:getstats()
		if stats ~= nil then
			stats = lineify.tolines(stats, 28)
			descy = lineify.rendertext(abilitysurface, stats, "LiberationMono-Regular", 15, {150,150,255}, true, 40, descy, false) + 30
		end
		
		local desc = ability:getdesc()
		if desc ~= nil then
			desc = lineify.tolines(desc, 28)
		          descy = lineify.rendertext(abilitysurface, desc, "LiberationMono-Regular", 15, {255,255,255}, true, 40, descy, false)
		end
		
		typedesc = lineify.rendertext(abilitysurface, self.typenames[i], "LiberationMono-Regular", 15, {255,255,255}, true, self.w/8, self.h-50, true, true)
		local keys = conf.keys[type]
		local key = keys[1]
		if key == nil then key = keys[2]
		elseif keys[2] ~= nil then key = key .. " or " .. keys[2] end
		if key == nil then key = "[UNBOUND]" end
		keydesc = lineify.rendertext(abilitysurface, key, "LiberationMono-Regular", 15, {255,255,255}, true, self.w/8, self.h-30, true, true)
		
		abilitysurface:draw(self.surface, self.w / 4 * (i-1), 0)
	end
end

function dialog:on_draw(dst_surface)
	self.surface:draw(dst_surface, self.dst_x, self.dst_y)
end

return dialog

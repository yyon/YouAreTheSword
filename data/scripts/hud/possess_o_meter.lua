local possess_o_meter = {}

local entitydata = require "enemies/entitydata"


function possess_o_meter:new(game)

  	local object = {}
  	setmetatable(object, self)
  	self.__index = self

  	object:initialize(game)

  	return object
end

function possess_o_meter:initialize(game)

  	self.game = game
  	self.surface = sol.surface.create(952, 25)
  	self.dst_x = 0
  	self.dst_y = 0
	self.stage_displayed = 0
  	self.all_sword_img = sol.surface.create("hud/sword_meter.png")
	self.sword_anim_setup = sol.sprite.create("hud/possess_o_meter")
end

function possess_o_meter:on_started()
	self.danger_sound_timer = nil
  	self:check(nil)
  	self:rebuild_surface()

end

--  check heart data and fix periodically
function possess_o_meter:check()

  	local need_rebuild = false
	
	local stage = 10
	
	hero = game:get_hero().entitydata
    	if hero ~= nil then
		-- stage = math.floor(hero.possess_clock / 7)
	end

	if stage ~= self.stage_displayed then
		need_rebuild = true
		self.stage_displayed = stage
		
	end

	

  	-- redraw only if something has changed
  	if need_rebuild then
    		self:rebuild_surface()
  	end

	--self.sword_anim_setup:set_animation("sword progress bar")

  	-- check again in 50ms
  	sol.timer.start(self, 50, function()
    		self:check()
  	end)
end


function possess_o_meter:rebuild_surface()

  	self.surface:clear()
	self.all_sword_img:draw_region(self.stage_displayed * 56, 0, 56, 25, self.surface, x, y)
	
end

function possess_o_meter:set_dst_position(x, y)
  	self.dst_x = x
  	self.dst_y = y
end

function possess_o_meter:on_draw(dst_surface)

  	local x, y = self.dst_x, self.dst_y
  	local width, height = dst_surface:get_size()
  	if x < 0 then
    		x = width + x
  	end
  	if y < 0 then
    		y = height + y
  	end
	self.surface:draw(dst_surface, x, y)
end

return possess_o_meter

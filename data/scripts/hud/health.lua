local health = {}

local entitydata = require "enemies/entitydata"

function health:new(game)

  	local object = {}
  	setmetatable(object, self)
  	self.__index = self

  	object:initialize(game)

  	return object
end

function health:initialize(game)

  	self.game = game
  	self.surface = sol.surface.create(90, 18)
  	self.dst_x = 0
  	self.dst_y = 0
  	self.empty_heart_sprite = sol.sprite.create("hud/empty_heart")
  	self.nb_max_hearts_displayed = game:get_max_life() / 4
  	self.nb_current_hearts_displayed = game:get_life()
  	self.all_hearts_img = sol.surface.create("hud/hearts.png")
end

function health:on_started()
	self.danger_sound_timer = nil
  	self:check()
  	self:rebuild_surface()

end

--  check heart data and fix periodically
function health:check()

  	local need_rebuild = false
	local nb_current_hearts = 0
	local nb_max_hearts = 0
	
	hero = game:get_hero().entitydata
    	if hero ~= nil then
     		nb_current_hearts = hero.life * 4
		nb_max_hearts = hero.maxlife
		
    	end

	self:set_dst_position(630-9*nb_max_hearts, 10)
    

  	--  max life
  	if nb_max_hearts ~= self.nb_max_hearts_displayed then
    		need_rebuild = true

    		if nb_max_hearts < self.nb_max_hearts_displayed then
      			-- fix max hearts if it changes (sword is handed off)
      			self.nb_current_hearts_displayed = nb_max_hearts
    		end

    		self.nb_max_hearts_displayed = nb_max_hearts
  	end

  	-- current life
  	if nb_current_hearts ~= self.nb_current_hearts_displayed then

    		need_rebuild = true
    		if nb_current_hearts < self.nb_current_hearts_displayed then
      			self.nb_current_hearts_displayed = self.nb_current_hearts_displayed - 1
    		else
      			self.nb_current_hearts_displayed = self.nb_current_hearts_displayed + 1
    		end
  	end

	-- do the danger animation
  	if self.game:is_started() then

    		if nb_current_hearts <= nb_max_hearts
        			and not self.game:is_suspended() then
      			need_rebuild = true
      			if self.empty_heart_sprite:get_animation() ~= "danger" then
        				self.empty_heart_sprite:set_animation("danger")
      			end
    		elseif self.empty_heart_sprite:get_animation() ~= "normal" then
      			need_rebuild = true
      			self.empty_heart_sprite:set_animation("normal")
    		end
  	end

  	-- redraw only if something has changed
  	if need_rebuild then
    		self:rebuild_surface()
  	end

  	-- check again in 50ms
  	sol.timer.start(self, 50, function()
    		self:check()
  	end)
end


function health:rebuild_surface()

  	self.surface:clear()

  	-- show the hearts
  	for i = 0, self.nb_max_hearts_displayed - 1 do
    		local x, y = (i % 10) * 9, math.floor(i / 10) * 9
    		self.empty_heart_sprite:draw(self.surface, x, y)
    		if i < math.floor(self.nb_current_hearts_displayed / 4) then
     			 -- full heart
      			self.all_hearts_img:draw_region(27, 0, 9, 9, self.surface, x, y)
    		end
  	end

  	-- last portion of heart
  	local i = math.floor(self.nb_current_hearts_displayed / 4)
  	local remaining_fraction = self.nb_current_hearts_displayed % 4
  	if remaining_fraction ~= 0 then
   		local x, y = (i % 10) * 9, math.floor(i / 10) * 9
    		self.all_hearts_img:draw_region((remaining_fraction - 1) * 9, 0, 9, 9, self.surface, x, y)
  	end
end

function health:set_dst_position(x, y)
  	self.dst_x = x
  	self.dst_y = y
end

function health:on_draw(dst_surface)

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

return health

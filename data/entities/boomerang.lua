local entity = ...

local Effects = require "enemies/effect"
require "scripts/movementaccuracy"

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start(tox, toy, hx, hy)
	self.bom_sprite = self:create_sprite("abilities/boomerang")
	local dist = self:get_distance(tox, toy)
	if dist > self.ability.range then
		dist = self.ability.range
	end

	local x, y = self:get_position()
	local angle = self:get_angle(tox, toy) - math.pi
	local movement = sol.movement.create("circle")
	movement:set_center(hx,hy)
	movement:set_radius(500)
	movement:set_radius_speed(1000)
	movement:set_clockwise(false)
	movement:set_loop_delay(0)
	movement:set_duration(2000)
	movement:start(self)

end

function entity:onhit()
	sol.audio.play_sound("arrow")
    self:remove()
end

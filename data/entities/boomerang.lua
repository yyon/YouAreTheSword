local entity = ...

local Effects = require "enemies/effect"
require "scripts/movementaccuracy"

function entity:on_created()
	self:set_optimization_distance(0)
end

function entity:start(tox, toy)
	self:create_sprite("abilities/boomerang")

	local x, y = self:get_position()
	local movement = sol.movement.create("circle")
	movement:set_center(x,y)
	movement:set_radius(500)
	movement:set_radius_speed(1000)
	movement:set_clockwise(false)
	movement:set_loop_delay(0)
	movement:set_duration(100)
	movement:start(self)

end

function entity:onhit()
	sol.audio.play_sound("arrow")
    self:remove()
end

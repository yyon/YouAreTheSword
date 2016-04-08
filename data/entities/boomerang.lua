local entity = ...

local Effects = require "enemies/effect"

local math = require "math"

sol.main.load_file("entities/projectile")(entity)

local speed = 1000
local xs, ys, xe, ye
local returned = 0

function entity:getdamage()
  local aspects = {}
  aspects.knockback = 100
  local damage = 0.5
  return damage, aspects
end

function entity:getspritename()
  return "abilities/boomerang"
end

function entity:getspeed()
	return speed
end

function entity:onhit()
	sol.audio.play_sound("arrow")
end

function entity:getmaxdist()
	return 500
end

function entity:onstart()
	xs, ys = self.movement:get_xy()
	print(xs, ys)
end

function entity:finish()
	self.movement:stop()
	if returned == 1 then
		self:remove()
	end
	self:start(self.ability, xs, ys)
	returned = 1
end
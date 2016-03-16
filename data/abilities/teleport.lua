local class = require "middleclass"
Ability = require "abilities/ability"
require "scripts/movementaccuracy"

TeleportAbility = Ability:subclass("TeleportAbility")

function TeleportAbility:initialize(entitydata)
	Ability.initialize(self, entitydata, "Teleporter", 600, "teleport", 0, 2550, true)
end

function TeleportAbility:doability()
	tox, toy = self.entitydata:gettargetpos()
	tox, toy = self:withinrange(tox, toy)
	
	d = self.entitydata.entity:get_distance(tox, toy)
	x, y = self.entitydata.entity:get_position()
	dx, dy = tox-x, toy-y
	canteleport = true
	for i=0,d,20 do
		p = i/d
		newdx, newdy = dx*p, dy*p
		if self.entitydata.entity:test_obstacles(newdx, newdy) then
			canteleport = false
			break
		end
	end
	
	if canteleport then
		self.entitydata.entity:set_position(tox, toy)
	
		-- animation
		entity = self.entitydata.entity
		map = entity:get_map()
		x,y,layer = entity:get_position()
		w,h = entity:get_size()
		entitydata = self.entitydata

		self.teleportentity = map:create_custom_entity({model="teleportanim", x=x, y=y, layer=2, direction=0, width=w, height=h})
		
		sol.audio.play_sound("teleport")
		
		self:finish()
	else
		self:finish(true)
	end
end

return TeleportAbility
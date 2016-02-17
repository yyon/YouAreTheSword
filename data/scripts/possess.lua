local game = ...

possess = {}

require "math"

function possess:possessrandom()
	map = game:get_map()
	hero = game:get_hero()
	
	entitieslist = {}
	for entity in map:get_entities("") do
		if entity:get_type() == "enemy" then
			entitieslist[#entitieslist+1] = entity
		end
	end
	
	entity = entitieslist[math.random(#entitieslist)]
	if entity ~= nil then
		hero:set_position(entity:get_position())
		hero:set_direction(entity:get_movement():get_direction4())
		
		hero:set_tunic_sprite_id(entity.main_sprite)
		
		entity:remove()
	end
end

return possess
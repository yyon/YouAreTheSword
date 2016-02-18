local game = ...

possess = {}

require "math"

function possess:possessrandom()
	map = game:get_map()
	hero = game:get_hero()
	
	entitieslist = {}
	for entity in map:get_entities("") do
		if entity.entitydata ~= nil then
			if not entity.entitydata.ishero then
				entitieslist[#entitieslist+1] = entity
			end
		end
	end
	
	entity = entitieslist[math.random(#entitieslist)]
	
	if entity ~= nil then
		if hero.entitydata ~= nil then
			hero.entitydata:throwsword(entity.entitydata)
		end
--		hero.entitydata:unpossess()
--		entity.entitydata:bepossessedbyhero()
	end
end

return possess
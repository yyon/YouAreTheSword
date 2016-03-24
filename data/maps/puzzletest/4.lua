local map = ...
local FiringBowAbility = require "abilities/firingBow"

map.dialogprefix = "puzzletest."

function map:on_started()
--	door_lever.entitydata.time = 10000
--	door2_lever.entitydata.time = 10000
	
	self:slowarrow(hero)
	for entity in self:get_entities("") do
		self:slowarrow(entity)
	end
end

function map:slowarrow(entity)
	if entity.entitydata ~= nil and entity.entitydata.theclass == "archer" then
		local bowability = FiringBowAbility:new(entity.entitydata)
		bowability.warmup = 5000
		entity.entitydata.specialability = bowability
	end
end

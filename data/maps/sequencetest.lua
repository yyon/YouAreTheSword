local my_map = ...

function my_map:on_started()
	local hero = self:get_hero()
	
	self.herosentitydata = hero.entitydata
	hero.entitydata:drop(hero, true)
	hero.entitydata = self.herosentitydata
end

function my_map:on_opening_transition_finished()
	hero.entitydata = nil
	
	hero:freeze()
	
	self:freezeeveryone()
	
	self:move("knight", "knightdest")
	self:move("cleric", "clericdest", function() self:advwalked() end)
end

function my_map:advwalked()
	self:look("knight", "cleric")
	self:look("cleric", "knight")
	
	self:startdialog("opening", function() self:testend() end)
end

function my_map:testend()
--	game:startdialog("test", function() self:finish() end)
	print("END")
	hero:unfreeze()
	self:finish()
end
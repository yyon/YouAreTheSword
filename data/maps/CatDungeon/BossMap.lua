local map = ...

map.dialogprefix = "catdungeon."

function map:on_opening_transition_finished()
	self:startcutscene()
	
	self:say("cat", "3", function()
	self:say("player", "4", function()
		self:finish()
	end)
	end)
end

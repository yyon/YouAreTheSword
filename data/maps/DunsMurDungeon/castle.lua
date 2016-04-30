local map = ...

map.dialogprefix = "castle."

local Effects = require "enemies/effect"

function map:on_opening_transition_finished()
	function dunsmur.entitydata:isvisible() return false end
	
	self:startcutscene()
	
	
	self:say("knight", "1", function()
		self:move("knight", "center", function() 
			self:move("knight", "escape", function() end)
		end)
		self:move("berserker", "center", function() 
			self:move("berserker", "escape", function() end)
		end)
		self:move("dunsmur", "escape", function() 
			dunsmur:remove()
			self:say("knight", "2", function()
				self:doend()
			end)
		end)
	end)
end

function map:doend()
	self:finish()
end

local map = ...

map.dialogprefix = "sequencetest."

function map:on_started()
	local hero = self:get_hero()
	
	game.instantdeath = true
	
	self.herosentitydata = hero.entitydata
	hero.entitydata:drop(hero, true)
	hero.entitydata = self.herosentitydata
end

function map:on_opening_transition_finished()
	hero.entitydata = nil
	
	hero:freeze()
	
	self:freezeeveryone()
	self:move("knight", "knightdest", function() self:look("knight", "cleric") end)
	self:move("cleric", "clericdest", function() self:advwalked() end)
end

function map:advwalked()
	self:look("cleric", "knight")
	
	self:startdialog("1", function()
		self:dialog1end()
	end)
end

function map:dialog1end()
	sol.audio.play_sound("door")
	self:wait(100, function()
		self:skeletonsenter()
	end)
end

function map:skeletonsenter()
	self:move("skeleton1", "skeleton1dest")
	self:move("skeleton2", "skeleton2dest", function()
		self:startfight()
	end)
end

function map:startfight()
	self:look("knight", "skeleton2")
	self:attack("skeleton1", "cleric", "FiringBowAbility")
	self:wait(50, function()
		self:attack("skeleton2", "knight", "FiringBowAbility")
	end)
	self:wait(100, function()
		self:attack("knight", "skeleton1", "ShieldAbility")
	end)
	self:wait(300, function()
		self:attack("cleric", "clericdodgedest", "SidestepAbility")
	end)
	self:wait(1000, function()
		self:move("cleric", "clericdest")
		self:look("cleric", "skeleton1")
		self:move("knight", "knightattackdest", function()
			self:attack("knight", "skeleton2", "SwordAbility")
			self:wait(500, function()
				self:move("knight", "knightattackdest2", function()
					self:attack("knight", "skeleton1", "SwordAbility")
					self:wait(500, function()
						self:endfight()
					end)
				end)
			end)
		end)
	end)
end

function map:endfight()
	self:move("knight", "knightpickupdest", function()
		self:look("cleric", "knight")
		self:startdialog("5", function()
			self:wait(500, function()
				knight.entitydata:bepossessedbyhero()
				self:attack("mage", "hero", "EarthquakeAbility", true)
				self:wait(2000, function()
					self:startdialog("6", function()
						self:look("hero", "knightattackdest2")
						self:wait(500, function()
							self:startdialog("7", function()
								self:testend()
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end

function map:testend()
	game.instantdeath = false
	hero:unfreeze()
	
	self:finish()
	
	self:freezeentity(cleric)
	self:setanim("cleric", "stopped")
	cleric.dialog = "cleric_afterwards"
end
local map = ...

map.dialogprefix = "sequencetest."

local Effects = require "enemies/effect"

function map:on_started()
	local hero = self:get_hero()

	game.instantdeath = true

--	self.herosentitydata = hero.entitydata
--	hero.entitydata:drop(hero, true)
--	hero.entitydata = self.herosentitydata
	hero.entitydata.main_sprite = "abilities/droppedsword"
	hero.entitydata:applytoentity()
end

function map:on_opening_transition_finished()
--	hero.entitydata = nil

--	hero:freeze()
--	self:freezeeveryone()

	cleric.entitydata.stats.defense = 1
	knight.entitydata.stats.defense = 1

	self:startcutscene()
	self.newentitypossesseffect:remove()

	self:move("knight", "knightdest", function() self:look("knight", "cleric") end)
	self:move("cleric", "clericdest", function() self:advwalked() end)
end

function map:advwalked()
	self:look("cleric", "knight")

	self:say("cleric", "1", function()
		self:say("knight", "2", function()
			self:say("cleric", "3", function()
				self:say("knight", "4", function()
					self:dialog1end()
				end)
			end)
		end)
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
		self:say("cleric", "4.1", function()
			self:startfight()
		end)
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
						self:say("knight", "4.2", function()
							self:endfight()
						end)
					end)
				end)
			end)
		end)
	end)
end

function map:endfight()
	self:move("knight", "knightpickupdest", function()
		self:look("cleric", "knight")
		self:say("knight", "5", function()
			self:wait(500, function()
--				local entitydata = knight.entitydata
--				entitydata:bepossessedbyhero()
--				self:freezeentity(entitydata.entity)
				self.newentitypossesseffect = Effects.PossessEffect(knight.entitydata)
				self.heroentitydata.entity:remove()
				self.heroentitydata.entity = nil
				self.heroentitydata = knight.entitydata
				self:attack("mage", "hero", "EarthquakeAbility", true)
				local hero = self:get_hero()
				local x, y = hero:get_position()
				knight.entitydata.positionlisteners[self] = function(x, y, layer)
					local dx = math.random(-50, 50)
					local dy = math.random(-50, 50)
					hero:set_position(x+dx, y+dy)
				end
				self:wait(2000, function()
					hero:set_position(x, y)
					knight.entitydata.positionlisteners[self] = nil
					self:say("knight", "6", function()
						self:look("knight", "knightattackdest2")
						self:wait(500, function()
							self:say("cleric", "7", function()
								self:say("knight", "8", function()
									self:startdialog("9", function()
										self:testend()
									end)
								end)
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

	self:finish()

	local hero = self:get_hero()
	hero.entitydata.stats.defense = 0.3
	cleric.entitydata.stats.defense = 0.3

	self:freezeentity(cleric.entitydata)
	self:setanim("cleric", "stopped")
	cleric.dialog = "cleric_afterwards"
end

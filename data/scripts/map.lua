local map = ...

local Effects = require "enemies/effect"
local class = require "middleclass"
local math = require "math"
local Grid = require ("jumper/grid") -- The grid class
local Pathfinder = require ("jumper/pathfinder") -- The pathfinder lass
local Choice = require "menus/choice"

local damagedisps = {}
local damagedisp = class("damagedisp")
function damagedisp:initialize(dmg, x, y)
	y = y - 50
	dmg = math.floor(dmg * 10 + 0.5)
	if dmg ~= 0 then
		self.dmg, self.x, self.y = dmg, x, y
		self.origy = self.y
		local font
		if dmg < 20 then
			font = "damagedisp1"
		else
			font = "damagedisp2"
		end

		local size = dmg/2+5
		if size < 10 then size = 10 end
		if size > 50 then size = 50 end

		local gb = 255 - (dmg / 100 * 255 * 2)
		if gb < 0 then gb = 0 end
		local col = {255, gb, gb}

		self.text = sol.text_surface.create({horizontal_alignement="center", vertical_alignement="middle", text=tostring(dmg), font=font, color=col, font_size=size})
	          self.w, self.h = self.text:get_size()
		self.x = self.x - self.w / 2
		damagedisps[self]=true
	end
end

function damagedisp:draw(dst_surface, cx, cy)
	self.text:draw(dst_surface, self.x-cx, self.y-cy)
	if not (game:is_paused() or game:is_suspended()) then
		self.y = self.y - 1
		if self.origy - self.y > 50 then
			damagedisps[self] = nil
		end
	end
end

local foundmonster = false
for entity in map:get_entities("") do
    if entity.get_destination_map ~= nil then
        local x, y, layer = entity:get_position()
        entity:set_position(x, y, 2)
    end
    if entity.entitydata ~= nil then
        if entity.entitydata.team ~= "adventurer" then
            foundmonster = true
        end
    end
end
if not foundmonster then
    map.nomonstersleft = true
end

local hero = map:get_hero()
if hero.entitydata ~= nil then
    if hero.entitydata.theclass == "debugger" then
        for entity in map:get_entities("") do
            if entity.entitydata ~= nil then
                if entity.entitydata.theclass == "debugger" then
                    entity.entitydata:kill()
                end
            end
        end
    end
end

function map:actuallydrawlifebars()
    local hero = self:get_hero()
    self:actuallydrawlifebar(hero)
    for entity in self:get_entities("") do
        self:actuallydrawlifebar(entity)
    end
end

function map:actuallydrawlifebar(entity)
    if entity.entitydata ~= nil and not entity.entitydata.dontdrawlifebar then
        entity.lifebarsurface = sol.surface.create(70, 8)

        local frame
        if entity.entitydata.life > 0 then
            frame = math.floor((1 - entity.entitydata.life / entity.entitydata.maxlife) * 49)
        else
            frame = 49
        end

        local lifebarsprite = game.lifebarsprite
        if entity.entitydata.team == "adventurer" then
            lifebarsprite = game.allieslifebarsprite
        end
        if entity.ishero then
            lifebarsprite = game.herolifebarsprite
        end
        lifebarsprite:set_frame(frame)
        lifebarsprite:draw(entity.lifebarsurface, 35, 1)

		if entity.entitydata.souls < 1 then
			if entity.entitydata.life > 0 then
	            frame = math.floor((1 - entity.entitydata.souls) * 49)
	        else
	            frame = 49
	        end

	        local soulbarsprite = game.soulbarsprite
	        soulbarsprite:set_frame(frame)
	        soulbarsprite:draw(entity.lifebarsurface, 35, 5)
		end
    end
end

map.ticker = Effects.Ticker(game, 100, function() map:actuallydrawlifebars() end)

function map:on_finished()
    self.ticker:remove()
    local hero = self:get_hero()
    hero.lifebarsurface = nil
end

function map:say(name, ...)
    self:camera(name)
    self:startdialog(...)
end

function map:drawlifebar(dst_surface, entity, cx, cy)
        if entity.entitydata ~= nil then
            local x, y = entity:get_position()

            if entity.entitydata.effects["possess"] ~= nil then
                if entity.eyessprite == nil then
                    entity.eyessprite = sol.sprite.create("adventurers/eyes")
                end

                local anim = entity.main_sprite:get_animation()
                if entity.eyessprite:has_animation(anim) then
                    if anim ~= entity.eyessprite:get_animation() then
                        entity.eyessprite:set_animation(anim)
                    end
                    local d = entity.main_sprite:get_direction()
                    if entity.eyessprite:get_num_directions() < d then
                        d = 0
                    end
                    entity.eyessprite:set_direction(d)

                    map:draw_sprite(entity.eyessprite, x, y)
                end
            end

            y = y - 65

--            map:draw_sprite(lifebarsprite, x, y)
            if entity.lifebarsurface ~= nil and not self.dontdrawlifebars then
                entity.lifebarsurface:draw(dst_surface, x-cx-35, y-cy-1)
            end
        end
end

function map:on_draw(dst_surface)
    local hero = map:get_hero()
    if hero.entitydata ~= nil then
        if not hero.entitydata.cantdraweyes then
            if hero:is_visible() then
                local anim = hero:get_animation()
                if hero.eyessprite:has_animation(anim) then
                    if anim ~= hero.eyessprite:get_animation() then
                        hero.eyessprite:set_animation(anim)
                    end
                    local d = hero:get_direction()
                    if hero.eyessprite:get_num_directions() < d then
                        d = 0
                    end
                    hero.eyessprite:set_direction(d)

                    local x, y = hero:get_position()
                    map:draw_sprite(hero.eyessprite, x, y)
                end
            end
        end
    end

    local cx, cy = self:get_camera_position()

    self:drawlifebar(dst_surface, hero, cx, cy)
    for entity in self:get_entities("") do
        self:drawlifebar(dst_surface, entity, cx, cy)
    end

    for dmgdisp, _ in pairs(damagedisps) do
	dmgdisp:draw(dst_surface, cx, cy)
    end
end

function map:freezeeveryone()
    for entity in self:get_entities("") do
        self:freezeentity(entity)
    end
    self:freezeentity(self:get_hero())
end

function map:freezeentity(entity)
    if entity.entitydata ~= nil then
        if entity.entitydata.mapfrozeneffect == nil then
            local newfreezeeffect = Effects.FreezeEffect:new(entity.entitydata)
            entity.entitydata.mapfrozeneffect = newfreezeeffect
            entity.entitydata:setanimation("stopped")
        end
    end
end

function map:unfreezeeveryone()
    for entity in self:get_entities("") do
        self:unfreezeentity(entity)
    end
    self:unfreezeentity(self:get_hero())
end

function map:unfreezeentity(entity)
    if entity.entitydata ~= nil then
        if entity.entitydata.mapfrozeneffect ~= nil then
            entity.entitydata.mapfrozeneffect:remove()
            entity.entitydata.mapfrozeneffect = nil
            entity.entitydata.manualtarget = nil
        end
    end
end

function map:wait(time, endfunction)
    self.waittimer = Effects.SimpleTimer(game, time, endfunction)
end

function map:move(name, target, endfunction, type, speed, stopdist)
    if type == nil then type = "straight" end
    if speed == nil then speed = 128 end

    self:setanim(name, "walking")

    local entity = map:get_entity(name)
    entity:stop_movement()
    local targetentity = map:get_entity(target)
    local movement = sol.movement.create("target")
    movement:set_speed(speed)
    movement:set_target(targetentity)
    movement:start(entity)

    if endfunction ~= nil then
        if stopdist == nil then
            function movement.on_finished(movement)
                self:setanim(name, "stopped")
                entity:stop_movement()
                endfunction()
            end
        else
            function movement.on_position_changed(movement)
                local d = entity:get_distance(targetentity)
                if d < stopdist then
                    self:setanim(name, "stopped")
                    entity:stop_movement()
                    endfunction()
                end
            end
        end
    end
end

function map:setanim(name, anim)
    local entity = map:get_entity(name)
    if entity.entitydata ~= nil then
        entity.entitydata:setanimation(anim)
    end
end

function map:startdialog(...)
    game:start_dialog(...)
end

function map:choice(dialog, choice1, choicefunct1, choice2, choicefunct2)
	self:startdialog(dialog)
	local choicemenu = Choice(game, choice1, choicefunct1, choice2, choicefunct2)
	sol.menu.start(game, choicemenu)
	game.dontshowpausemenu = true
	game:set_paused(true)
end

function map:look(name, target)
    local entity = map:get_entity(name)
    entity:stop_movement()
    local targetentity = map:get_entity(target)
    local d = entity:get_direction4_to(targetentity)
    entity.entitydata:setdirection(d)
    self:setanim(name, "stopped")
end

function map:attack(name, target, attackname, skiptimer)
    self:look(name, target)

    local entitydata = map:get_entity(name).entitydata
    local targetentity = map:get_entity(target)
    entitydata.manualtarget = targetentity

    local allattacks = {}
    for _, abil in pairs(entitydata.normalabilities) do allattacks[abil]=true end
    for _, abil in pairs(entitydata.transformabilities) do allattacks[abil]=true end
    for _, abil in pairs(entitydata.blockabilities) do allattacks[abil]=true end
    for _, abil in pairs(entitydata.specialabilities) do allattacks[abil]=true end

    local ability
    for abil, _ in pairs(allattacks) do
        if abil.class.name == attackname then
            ability = abil
            break
        end
    end

    if ability == nil then
        print("Couldn't find ability!")
    else
        local oldwarmup, oldcooldown
        if skiptimer then
            oldwarmup, oldcooldown = ability.warmup, ability.cooldown
            ability.warmup, ability.cooldown = 0, 0
        end
        ability:start()
        if skiptimer then
            ability.warmup, ability.cooldown = oldwarmup, oldcooldown
        end
    end
end

--[[function map:camera(target, callback, speed)
    if speed == nil then speed = 128 end
    local entity = map:get_entity(target)
    local x, y = entity:get_position()
    self:move_camera(x, y, speed, callback, 0, 999999)
end
--]]

function map:camera(name)
    local entity = self:get_entity(name)
    local hero = self:get_hero()
    hero:set_position(entity:get_position())
end

function map:startcutscene()
    self:deattachcamera()

    local hero = self:get_hero()
    self:freezeeveryone()
    hero:freeze()

    self.dontdrawlifebars = true
end

function map:finish()
    self:unfreezeeveryone()
    local hero = self:get_hero()
    hero:unfreeze()

    self.dontdrawlifebars = false

    self:reattachcamera()
end

function map:deattachcamera()
    local hero = self:get_hero()
    local newentity = hero.entitydata:unpossess("player")
--    newentity:set_name("player")
    self.heroentitydata = newentity.entitydata
    self.newentitypossesseffect = Effects.PossessEffect:new(newentity.entitydata)
    hero:set_tunic_sprite_id("adventurers/transparent")
end

function map:reattachcamera()
    self.newentitypossesseffect:remove()
    self.heroentitydata:bepossessedbyhero()
end

function map:damagedisplay(damage, x, y)
    damagedisp:new(damage, x, y)
end

function map:getgrid(NODESIZE)
	local mapw, maph = map:get_size()
	mapw, maph = mapw/NODESIZE, maph/NODESIZE

	if self.grid == nil then
		self.grid = {}
		local i = 0

		for x=0,mapw do
			for y=0,maph do
				i = i + 1
				self.grid[i] = {x=x, y=y}
			end
		end
	end

	return self.grid, mapw, maph
end

function map:onpuzzle()
	self:puzzleabilities(self:get_hero())
	self:get_hero().swordtransform = nil
	for entity in self:get_entities("") do
		self:puzzleabilities(entity)
	end
end

local FiringBowAbility = require "abilities/firingBow"
local StompAbility = require "abilities/stomp"
local LightningAbility = require "abilities/lightning"
local SwordAbility = require "abilities/sword"
local NothingAbility = require "abilities/nothing"

function map:puzzleabilities(entity)
	local entitydata = entity.entitydata
	if entitydata ~= nil then
		entitydata.puzzled = {entitydata.swordability, entitydata.blockability, entitydata.transformability, entitydata.specialability}
		entitydata.swordability = entitydata.normalabilities[1]
		entitydata.blockability = NothingAbility:new(entitydata)--entitydata.blockabilities[1]
		entitydata.transformability = NothingAbility:new(entitydata)--entitydata.transformabilities[1]
		entitydata.specialability = entitydata.specialabilities[1]

		if entitydata.theclass == "archer" then
			local bowability = FiringBowAbility:new(entitydata)
			bowability.warmup = 5000
			entitydata.specialability = bowability
		elseif entitydata.theclass == "berserker" then
			entitydata.swordability = StompAbility:new(entitydata)
			local stompability = StompAbility:new(entitydata)
			stompability.warmup = 5000
			entitydata.specialability = stompability
		elseif entitydata.theclass == "mage" then
			entitydata.swordability = LightningAbility:new(entitydata)
			local lightningability = LightningAbility:new(entitydata)
			lightningability.warmup = 5000
			entitydata.specialability = lightningability
		elseif entitydata.theclass == "knight" then
			entitydata.swordability = SwordAbility:new(entitydata)
			local a = SwordAbility:new(entitydata)
			a.warmup = 5000
			entitydata.specialability = a
		elseif entitydata.theclass == "cleric" then
			entitydata.swordability = SwordAbility:new(entitydata)
			entitydata.specialability = NothingAbility:new(entitydata)
		end
	end
end

function map:offpuzzle()
	self:unpuzzle(self:get_hero())
	for entity in self:get_entities("") do
		self:unpuzzle(entity)
	end
end

function map:unpuzzle(entity)
	local entitydata = entity.entitydata
	if entitydata ~= nil then
		if entitydata.puzzled ~= nil then
			entitydata.swordability = entitydata.puzzled[1]
			entitydata.blockability = entitydata.puzzled[2]
			entitydata.transformability = entitydata.puzzled[3]
			entitydata.specialability = entitydata.puzzled[4]
			entitydata.puzzled = nil
		end
	end
end

if map:get_floor() == 1 then
	map:onpuzzle()
else
	map:offpuzzle()
end

function map:togrid(x, y)
	return math.floor(x/8+0.5), math.floor(y/8+0.5)
end

function map:fromgrid(x, y)
	return x*8, y*8
end

function map:getclosestgrid(x, y)
	local left, right = math.floor(x/8), math.ceil(x/8)
	local top, bottom = math.floor(y/8), math.ceil(y/8)

	if self.gridtable[left][top] == 0 then return left, top end
	if self.gridtable[left][bottom] == 0 then return left, bottom end
	if self.gridtable[right][top] == 0 then return right, top end
	if self.gridtable[right][bottom] == 0 then return right, bottom end
end

function map:printgrid(gridtable)
	if gridtable == nil then gridtable = self.gridtable end
	local mapw, maph = self:get_size()
	local gridw, gridh = self:togrid(mapw, maph)

	for y = 1,gridh do
		local line = ""
		for x = 1,gridw do
			if gridtable[x][y] == 0 then
				line = line .. " "
			elseif gridtable[x][y] == 1 then
				line = line .. "#"
			else
				line = line .. gridtable[x][y]
			end
		end
		print(line)
	end
end

function map:copygrid()
	local newgrid = {}
	local mapw, maph = self:get_size()
	local gridw, gridh = self:togrid(mapw, maph)
	for x=1,gridw do
		newgrid[x] = {}
		for y = 1,gridh do
			newgrid[x][y] = self.gridtable[x][y]
		end
	end
	return newgrid
end

function map:calcgrid()
	local grid = {}
	local mapw, maph = self:get_size()
	local gridw, gridh = self:togrid(mapw, maph)

	local hero = self:get_hero()
	local herox, heroy = hero:get_position()

	for x = 1,gridw do
		grid[x] = {}
		for y = 1,gridh do
			local realx, realy = self:fromgrid(x, y)
			local dx, dy = realx-herox, realy-heroy
			if hero:test_obstacles(dx, dy) then
				grid[x][y] = 1
			else
				grid[x][y] = 0
			end
		end
	end

	self.gridtable = grid
	self.grid = Grid(grid)
	self.pathfinder = Pathfinder(self.grid, 'JPS', 0)
--	self.pathfinder:setMode("ORTHOGONAL")
end

map:calcgrid()

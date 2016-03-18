local map = ...

local Effects = require "enemies/effect"

for entity in map:get_entities("") do
    if entity.get_destination_map ~= nil then
        local x, y, layer = entity:get_position()
        entity:set_position(x, y, 2)
    end
end

function map:drawlifebar(entity)
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
            map:draw_sprite(lifebarsprite, x, y)
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

    self:drawlifebar(hero)
    for entity in self:get_entities("") do
        self:drawlifebar(entity)
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

function map:finish()
    self:unfreezeeveryone()
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

function map:look(name, target)
    local entity = map:get_entity(name)
    entity:stop_movement()
    local targetentity = map:get_entity(target)
    local d = entity:get_direction4_to(targetentity)
    entity.entitydata:setdirection(d)
    self:setanim(name, "stopped")
end

function map:attack(name, target, attackname, skiptimer)
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

function map:camera(target, callback, speed)
    if speed == nil then speed = 128 end
    local entity = map:get_entity(target)
    local x, y = entity:get_position()
    self:move_camera(x, y, speed, callback, 0, 999999)
end

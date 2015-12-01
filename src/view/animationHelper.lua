
local charset = {}
charset.default = love.graphics.newImage("img/chars/charset.png")
charset.karen = love.graphics.newImage("img/chars/karen.png")
charset.tim = love.graphics.newImage("img/chars/tim.png")
charset.lew = love.graphics.newImage("img/chars/lew.png")
charset.marketwoman = love.graphics.newImage("img/chars/marketwoman.png")


animationHelper = {}

local quads = nil

function animationHelper.init()
    quads = {}
    for x = 1, math.floor(charset.default:getWidth() / C_CHAR_SIZE) - 1 do
        quads[x] = {}
        for y = 1, math.floor(charset.default:getHeight() / C_CHAR_SIZE) - 1 do
            quads[x][y] = love.graphics.newQuad( (x-1) * C_CHAR_SIZE, (y-1) * C_CHAR_SIZE, C_CHAR_SIZE, C_CHAR_SIZE, charset.default:getDimensions() )
        end
    end
end


function animationHelper.draw(entity)
    if charset[entity.charset] then
        local cycle = entity.cycle + 1
        if entity.animation then cycle = entity.animation.timer + 1 end
        cycle = math.floor(cycle)
        love.graphics.draw(charset[entity.charset], quads[cycle][entity.anim], entity.posd.x * C_TILE_SIZE - C_CHAR_MOD_X, entity.posd.y * C_TILE_SIZE - C_CHAR_MOD_Y)
    else
        log:msg("error", "Missing entity tileset", entity.charset)
    end
end


function animationHelper.update(entity, dt)
    local mod = 1
    if entity.id == 1 and love.keyboard.isDown(KEY_SPRINT) then
        mod = 2
    end
    if entity.dir == "up" then entity.anim = 9 end
    if entity.dir == "left" then entity.anim = 10 end
    if entity.dir == "down" then entity.anim = 11 end
    if entity.dir == "right" then entity.anim = 12 end
    if entity.walking then
        entity.cycle = entity.cycle + dt * CHAR_ANIM * mod
        while entity.cycle >= 9 do entity.cycle = entity.cycle - 9 end
    else
        entity.cycle = 1
        if entity.anim > 4 then entity.anim = entity.anim - 8 end
    end
    if entity.animation then
        entity.animation.timer = entity.animation.timer + dt * CHAR_ANIM_WORK
        if entity.dir == "up" then entity.anim = 13 end
        if entity.dir == "left" then entity.anim = 14 end
        if entity.dir == "down" then entity.anim = 15 end
        if entity.dir == "right" then entity.anim = 16 end
        if entity.animation.timer >= 6 then
            entity.animation.timer = entity.animation.timer - 6
            entity.animation.cycles = entity.animation.cycles - 1
            if entity.animation.cycles <= 0 then
                entity:animationFinished()
            end
        end
    end
end

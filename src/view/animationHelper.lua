
local charset = {}
charset.default = love.graphics.newImage("img/chars/charset.png")
charset.karen = love.graphics.newImage("img/chars/karen.png")

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
    love.graphics.draw(charset[entity.charset], quads[math.floor(entity.cycle + 1)][entity.anim], entity.posd.x * C_TILE_SIZE - C_CHAR_MOD_X, entity.posd.y * C_TILE_SIZE - C_CHAR_MOD_Y)
end


function animationHelper.update(entity, dt)
    if entity.dir == "up" then entity.anim = 9 end
    if entity.dir == "left" then entity.anim = 10 end
    if entity.dir == "down" then entity.anim = 11 end
    if entity.dir == "right" then entity.anim = 12 end
    if entity.walking then
        entity.cycle = entity.cycle + dt * CHAR_ANIM
        while entity.cycle >= 9 do entity.cycle = entity.cycle - 9 end
    else
        entity.cycle = 1
        if entity.anim > 4 then entity.anim = entity.anim - 8 end
    end
end

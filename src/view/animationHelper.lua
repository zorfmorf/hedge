
local charset = love.graphics.newImage("img/chars/charset.png")

animationHelper = {}

local quads = nil

function animationHelper.init()
    quads = {}
    for x = 1, math.floor(charset:getWidth() / C_CHAR_SIZE) - 1 do
        quads[x] = {}
        for y = 1, math.floor(charset:getHeight() / C_CHAR_SIZE) - 1 do
            quads[x][y] = love.graphics.newQuad( (x-1) * C_CHAR_SIZE, (y-1) * C_CHAR_SIZE, C_CHAR_SIZE, C_CHAR_SIZE, charset:getDimensions() )
        end
    end
end


function animationHelper.draw(entity)
    love.graphics.draw(charset, quads[1][3], entity.pos.x * C_TILE_SIZE - C_CHAR_MOD_X, entity.pos.y * C_TILE_SIZE - C_CHAR_MOD_Y)
end


local charset = love.graphics.newImage("img/chars/charset.png")

Player = Class{}

local function createQuad(x, y)
    return love.graphics.newQuad( (x-1) * C_CHAR_SIZE, (y-1) * C_CHAR_SIZE, C_CHAR_SIZE, C_CHAR_SIZE, charset:getDimensions() )
end


function Player:init()
    self. id = 1 -- player always has id 1, only one player allowed at all times
    self.pos = { x=0, y=0 }
    self.quad = createQuad(1, 3)
end


function Player:place(x, y)
    self.pos = { x=x, y=y }
end


function Player:update(dt)
    
end


function Player:draw()
    love.graphics.draw(charset, self.quad, self.pos.x * C_TILE_SIZE - C_CHAR_MOD_X, self.pos.y * C_TILE_SIZE - C_CHAR_MOD_Y)
end

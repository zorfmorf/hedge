--[[--

    Texture atlas container, handles
     * texture
     * quads
     * spritebatch
    all in one

--]]--

TexAtlas = Class{}


function TexAtlas:init(path)
    self.img = love.graphics.newImage(path)
    self:update()
    
    self.quads = {}
    for i = 0, math.floor(self.img:getWidth() / C_TILE_SIZE) - 1 do
        self.quads[i] = {}
        for j = 0, math.floor(self.img:getHeight() / C_TILE_SIZE) - 1 do
            self.quads[i][j] = love.graphics.newQuad( i * C_TILE_SIZE, j * C_TILE_SIZE, C_TILE_SIZE, C_TILE_SIZE, self.img:getDimensions())
        end
    end
    log:msg("verbose", "Initiated texture atlas", path)
end


-- 
function TexAtlas:update()
    local factor = math.floor((screen.w * screen.h) * 2 / (C_TILE_SIZE * C_TILE_SIZE))
    self.batch_floor = love.graphics.newSpriteBatch(self.img, factor * 2)
    self.batch_floor2 = love.graphics.newSpriteBatch(self.img, factor)
    self.batch_object = love.graphics.newSpriteBatch(self.img, factor)
    self.batch_overlay = love.graphics.newSpriteBatch(self.img, factor)
    log:msg("verbose", "Updated texatlas size with factor", factor)
end


function TexAtlas:addFloorQuad(x, y, i, j)
    self.batch_floor:add(self.quads[x][y], i * C_TILE_SIZE, j * C_TILE_SIZE)
end


function TexAtlas:addFloor2Quad(x, y, i, j)
    self.batch_floor2:add(self.quads[x][y], i * C_TILE_SIZE, j * C_TILE_SIZE)
end


function TexAtlas:addObjectQuad(x, y, i, j)
    self.batch_object:add(self.quads[x][y], i * C_TILE_SIZE, j * C_TILE_SIZE)
end


function TexAtlas:addOverlayQuad(x, y, i, j)
    self.batch_overlay:add(self.quads[x][y], i * C_TILE_SIZE, j * C_TILE_SIZE)
end


function TexAtlas:clear()
    self.batch_floor:clear()
    self.batch_floor2:clear()
    self.batch_object:clear()
    self.batch_overlay:clear()
end

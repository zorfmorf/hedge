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
    self.batch_floor = love.graphics.newSpriteBatch(self.img, 2000)
    self.batch_floor2 = love.graphics.newSpriteBatch(self.img)
    self.batch_object = love.graphics.newSpriteBatch(self.img)
    self.batch_overlay = love.graphics.newSpriteBatch(self.img)
    
    self.quads = {}
    for i = 0, math.floor(self.img:getWidth() / C_TILE_SIZE) - 1 do
        self.quads[i] = {}
        for j = 0, math.floor(self.img:getHeight() / C_TILE_SIZE) - 1 do
            self.quads[i][j] = love.graphics.newQuad( i * C_TILE_SIZE, j * C_TILE_SIZE, C_TILE_SIZE, C_TILE_SIZE, self.img:getDimensions())
        end
    end
end


-- 
function TexAtlas:update(dt)
    
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

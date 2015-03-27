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
    self.batch = love.graphics.newSpriteBatch(self.img)
    
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


function TexAtlas:addQuad(x, y, i, j)
    self.batch:add(self.quads[x][y], i * C_TILE_SIZE, j * C_TILE_SIZE)
end

-- 
function TexAtlas:draw()
    love.graphics.draw(self.batch)
end

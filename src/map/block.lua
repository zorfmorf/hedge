--[[
--  A block describes a nxn tile block of map
--  It contains texture, collision, actor and trigger information
--  Blocks are loaded and unloaded dynamically on player movement.
--]]

Block = Class{}


-- x and y parameter of block position in overworld
function Block:init(x, y)
    self.x = x
    self.y = y
    self.tiles = {}
    for i = 0, C_BLOCK_SIZE - 1 do
        self.tiles[i] = {}
        for j = 0, C_BLOCK_SIZE - 1 do
            self.tiles[i][j] = { 1, math.random(0, 24), math.random(0, 24) }
        end
    end
end


function Block:update(dt)
    
end


function Block:draw()
    
    local at = tilesetreader:getAtlanti()
    
    for i,row in pairs(self.tiles) do
        for j,tile in pairs(row) do
            at[tile[1]]:addQuad(tile[2], tile[3], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
        end
    end
end

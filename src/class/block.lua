--[[
--  A block describes a nxn tile block of map
--  It contains texture, collision actor and trigger information
--  Blocks are loaded and unloaded dynamically on player movement.
--]]

Block = Class{}

function Block:init()
    self.tiles = {}
    for i = 1, C_BLOCK_SIZE do
        self.tiles[i] = {}
        for j = 1, C_BLOCK_SIZE do
            self.tiles[i][j] = 1
        end
    end
end


function Block:update(dt)
    
end


function Block:draw()
    
end

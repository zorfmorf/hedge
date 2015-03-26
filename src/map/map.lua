--[[
--  A map contains an arbitrary amount of
--  connected blocks
--]]

Map = Class{}

function Map:init()
    self.blocks = {}
    self:createBlock(0, 0)
end


-- create/overwrite block at given position
function Map:createBlock(x, y)
    if not self.blocks[x] then self.blocks[x] = {} end
    self.blocks[x][y] = Block(x, y)
end


-- 
function Map:update(dt)
    
end


-- 
function Map:draw()
    for x,row in pairs(self.blocks) do
        for y,block in pairs(row) do
            block:draw()
        end
    end
end

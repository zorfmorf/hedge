--[[
--  A map contains an arbitrary amount of
--  connected blocks
--]]

Map = Class{}

function Map:init()
    self.blocks = {}
    for i = 0,1 do
        for j = 0,1 do
            self:createBlock(i, j)
        end
    end
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

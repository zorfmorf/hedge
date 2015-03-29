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
            -- TODO: only draw if on screen
            block:draw()
        end
    end
end


function Map:setTile(x, y, ai, ax, ay)
    local bx = math.floor(x / C_BLOCK_SIZE)
    local by = math.floor(y / C_BLOCK_SIZE)
    if self.blocks[bx] and self.blocks[bx][by] then
        local tx = x % C_BLOCK_SIZE
        local ty = y % C_BLOCK_SIZE
        self.blocks[bx][by]:set(tx, ty, ai, ax, ay)
    end
end

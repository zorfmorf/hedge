--[[
--  A map contains an arbitrary amount of
--  connected blocks
--]]

Map = Class{}

function Map:init()
    self.blocks = {}
end


-- create/overwrite block at given position
function Map:createBlock(x, y)
    if not self.blocks[x] then self.blocks[x] = {} end
    self.blocks[x][y] = Block(x, y)
end


-- 
function Map:update(dt)
    
end


-- Draw all blocks that are at least partially on the screen
function Map:draw()
    
    local wx, wy = camera:worldCoords(0, 0)
    local bx = math.floor((wx / C_BLOCK_SIZE) / C_TILE_SIZE)
    local by = math.floor((wy / C_BLOCK_SIZE) / C_TILE_SIZE)
    local bxe = math.floor(((wx + screen.w) / C_BLOCK_SIZE) / C_TILE_SIZE)
    local bye = math.floor(((wy + screen.h) / C_BLOCK_SIZE) / C_TILE_SIZE)
    
    for x = bx, bxe do
        for y = by, bye do
            if self.blocks[x] and self.blocks[x][y] then
                self.blocks[x][y]:draw()
            end
        end
    end
    
end


function Map:setTile(x, y, tile, object, overlay, block)
    
    local bx = math.floor(x / C_BLOCK_SIZE)
    local by = math.floor(y / C_BLOCK_SIZE)
    
    if not self.blocks[bx] then self.blocks[bx] = {} end
    if not self.blocks[bx][by] then self.blocks[bx][by] = Block(bx, by) end
    
    local tx = x % C_BLOCK_SIZE
    local ty = y % C_BLOCK_SIZE
    self.blocks[bx][by]:set(tx, ty, tile, object, overlay, block)
end


function Map:getTile(x, y)
    local bx = math.floor(x / C_BLOCK_SIZE)
    local by = math.floor(y / C_BLOCK_SIZE)
    
    if self.blocks[bx] and self.blocks[bx][by] then 
        return self.blocks[bx][by].tiles[x - bx * C_BLOCK_SIZE][y - by * C_BLOCK_SIZE]
    end
    
    return nil
end

--[[
--  A block describes a nxn tile block of map
--  It contains texture, collision, actor and trigger information
--  Blocks are loaded and unloaded dynamically on player movement.
--  Each block has a 2d array of tiles, each tile has up to three textures:
--  floor, object, overlay
--]]

Block = Class{}


-- x and y parameter of block position in overworld
function Block:init(x, y)
    -- print( "Block init", x, y )
    self.x = x
    self.y = y
    self.tiles = {}
    for i = 0, C_BLOCK_SIZE - 1 do
        self.tiles[i] = {}
        for j = 0, C_BLOCK_SIZE - 1 do
            self.tiles[i][j] = { floor = nil, object = nil, overlay = nil, block = true, event = nil }
        end
    end
end


function Block:update(dt)
    
end


-- set the tile to the defined value
-- floor : { textureatlas_index, texture_x, texture_y }
-- object : { textureatlas_index, texture_x, texture_y }
-- overlay : { textureatlas_index, texture_x, texture_y }
-- block : if the tile blocks movement
-- event : id of event triggered by this tile
function Block:set(x, y, floor, object, overlay, block, event)
    local tile = self.tiles[x][y]
    if floor then tile.floor = floor end
    if object then tile.object = object end
    if overlay then tile.overlay = overlay end
    tile.block = block
    if event then tile.event = event end
end


function Block:delete(x, y)
    self.tiles[x][y] = { floor = nil, object = nil, overlay = nil, block = true, event = nil }
end


-- checks if no information is stored in this block
function Block:isEmpty()
    for i = 0, C_BLOCK_SIZE - 1 do
        for j = 0, C_BLOCK_SIZE - 1 do
            local t = self.tiles[i][j]
            if t.floor or t.object or t.overlay or t.event then return false end
        end
    end
    return true
end


-- add an event trigger to the tile
-- if event fires depends is coded into the event itself
function Block:addEvent(x, y, event)
    self.tiles[x][y].event = event
end


function Block:draw()
    
    local at = tilesetreader:getAtlanti()
    
    for i,row in pairs(self.tiles) do
        for j,tile in pairs(row) do
            if tile.floor then 
                at[tile.floor[1]]:addQuad(tile.floor[2], tile.floor[3], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
            end
            if tile.object then 
                at[tile.object[1]]:addQuad(tile.object[2], tile.object[3], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
            end
            if tile.overlay then 
                at[tile.overlay[1]]:addQuad(tile.overlay[2], tile.overlay[3], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
            end
        end
    end
end

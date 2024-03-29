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
    self.x = x
    self.y = y
    self.tiles = {}
    for i = 0, C_BLOCK_SIZE - 1 do
        self.tiles[i] = {}
        for j = 0, C_BLOCK_SIZE - 1 do
            self.tiles[i][j] = { floor = nil, floor2 = nil, object = nil, overlay = nil, block = true, event = nil, npc = nil }
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
function Block:set(x, y, floor, floor2, object, overlay, block, event, npc)
    
    local layer = editorHandler:getLayerToggles()
    
    local tile = self.tiles[x][y]
    if floor and layer.floor1 then 
        tile.floor = floor
        
        -- dirty hack to make comparisons easier
        for name,v in pairs(texture) do
            if name:sub(1, 6) == "field." and isEqual(floor, v) then
                tile.plowed = true
                if name == "field.inner" then
                    tile.plantable = true
                end
            end
        end
    end
    if floor2 and layer.floor2 then tile.floor2 = floor2 end
    if object and layer.object then tile.object = object end
    if overlay and layer.overlay then tile.overlay = overlay end
    tile.block = block
    if event then tile.event = event end
    if npc then tile.npc = npc end
end


function Block:delete(x, y)
    
    local layer = editorHandler:getLayerToggles()
    
    local tile = self.tiles[x][y]
    
    if layer.floor1 then tile.floor = nil end
    if layer.floor2 then tile.floor2 = nil end
    if layer.object then tile.object = nil end
    if layer.overlay then tile.overlay = nil end
    
    self.tiles[x][y] = { floor = tile.floor, floor2 = tile.floor2, object = tile.object, overlay = tile.overlay, block = true, event = nil }
end


-- checks if no information is stored in this block
function Block:isEmpty()
    for i = 0, C_BLOCK_SIZE - 1 do
        for j = 0, C_BLOCK_SIZE - 1 do
            local t = self.tiles[i][j]
            if t.floor or t.floor2 or t.object or t.overlay or t.event then return false end
        end
    end
    return true
end


-- add an event trigger to the tile
-- if event fires depends is coded into the event itself
function Block:addEvent(x, y, event)
    self.tiles[x][y].event = event
end


function Block:draw(outline)
    
    if outline then
        love.graphics.rectangle("line", self.x * C_BLOCK_SIZE * C_TILE_SIZE, self.y * C_BLOCK_SIZE * C_TILE_SIZE, C_BLOCK_SIZE * C_TILE_SIZE, C_BLOCK_SIZE * C_TILE_SIZE)
    else
        if not game.editmode then
            for i = 0, C_BLOCK_SIZE - 1 do
                for j = 0, C_BLOCK_SIZE - 1 do
                    
                    local tile = self.tiles[i][j]
                    
                    if tile.floor then
                        local t = game.mapping[tile.floor[1]][tile.floor[2]][tile.floor[3]]
                        game.atlas:addFloorQuad(t[1], t[2], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
                    end
                    if tile.floor2 then
                        local t = game.mapping[tile.floor2[1]][tile.floor2[2]][tile.floor2[3]]
                        game.atlas:addFloor2Quad(t[1], t[2], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
                    end
                    if tile.object then
                        local t = game.mapping[tile.object[1]][tile.object[2]][tile.object[3]]
                        game.atlas:addObjectQuad(t[1], t[2], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
                    end
                    if tile.overlay then
                        local t = game.mapping[tile.overlay[1]][tile.overlay[2]][tile.overlay[3]]
                        game.atlas:addOverlayQuad(t[1], t[2], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
                    end
                end
            end
            
        else
            local at = tilesetreader:getAtlanti()
            for i,row in pairs(self.tiles) do
                for j,tile in pairs(row) do
                    if tile.floor then 
                        at[tile.floor[1]]:addFloorQuad(tile.floor[2], tile.floor[3], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
                    end
                    if tile.floor2 then 
                        at[tile.floor2[1]]:addFloor2Quad(tile.floor2[2], tile.floor2[3], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
                    end
                    if tile.object then 
                        at[tile.object[1]]:addObjectQuad(tile.object[2], tile.object[3], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
                    end
                    if tile.overlay then 
                        at[tile.overlay[1]]:addOverlayQuad(tile.overlay[2], tile.overlay[3], i + self.x * C_BLOCK_SIZE, j + self.y * C_BLOCK_SIZE)
                    end
                end
            end
        end
    end
end

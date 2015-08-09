--[[
--  A map contains an arbitrary amount of
--  connected blocks
--]]

Map = Class{}

function Map:init(name)
    self.name = name
    hud_edit:setMapName(name) -- dirty to do it this way, what happens if we have multiple map objects simultaneously?
    self.blocks = {} -- actual block data
    self.spawns = {} -- spawn points, <id><pos> table. if none are set, player spawns at 0, 0
    self.entities = {}
    
    -- set boundaries for camera
    self.bound = { min={ x=0, y=0 }, max={ x=0, y=0 }}
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
    love.graphics.setColor(Color.WHITE)
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


-- set some or all values for a tile.
-- nil values won't override old values (intended)
-- exception: block value WILL override for reaons
function Map:setTile(x, y, tile, tile2, object, overlay, block, event, npc, delete)
    
    local bx = math.floor(x / C_BLOCK_SIZE)
    local by = math.floor(y / C_BLOCK_SIZE)
    
    if not self.blocks[bx] then self.blocks[bx] = {} end
    if not self.blocks[bx][by] then self.blocks[bx][by] = Block(bx, by) end
    
    local tx = x % C_BLOCK_SIZE
    local ty = y % C_BLOCK_SIZE
    
    if delete then
        self.blocks[bx][by]:delete(tx, ty)
    else
        -- adjust map boundary if necessary
        if tile or object or overlay then
            if x < self.bound.min.x then self.bound.min.x = x end
            if y < self.bound.min.y then self.bound.min.y = y end
            if x > self.bound.max.x then self.bound.max.x = x end
            if y > self.bound.max.y then self.bound.max.y = y end
        end
        
        -- then set the tile
        self.blocks[bx][by]:set(tx, ty, tile, tile2, object, overlay, block, event, npc)
    end
end


function Map:toggleWalkable(x, y)
    local tile = self:getTile(x, y)
    if tile then tile.block = not tile.block end
end


-- helper function to get the tile behind a tile coordinate
-- you probably want to use this as blocks have their own coordinate system
function Map:getTile(x, y)
    local bx = math.floor(x / C_BLOCK_SIZE)
    local by = math.floor(y / C_BLOCK_SIZE)
    
    if self.blocks[bx] and self.blocks[bx][by] then 
        return self.blocks[bx][by].tiles[x - bx * C_BLOCK_SIZE][y - by * C_BLOCK_SIZE]
    end
    
    return nil
end


-- change event value for tile
function Map:changeEvent(x, y, event)
    local tile = self:getTile(x, y)
    if tile then tile.event = event end
end


-- delete tile and block if necessary
function Map:deleteTile(x, y)
    local tile = self:getTile(x, y)
    if tile then
        
        self:setTile(x, y, nil, nil, nil, nil, nil, nil, nil, true)
        
        local bx = math.floor(x / C_BLOCK_SIZE)
        local by = math.floor(y / C_BLOCK_SIZE)
        
        if self.blocks[bx][by]:isEmpty() then self.blocks[bx][by] = nil end
    end
end


-- add a spawn point or remove a spawn point at the given location
function Map:toggleSpawn(x, y)
    for key,value in pairs(self.spawns) do
        if value.x == x and value.y == y then
            self.spawns[key] = nil
            return
        end
    end
    local i = 1
    while self.spawns[i] do
        i = i + 1
    end
    self.spawns[i] = { x=x, y=y}
end


-- deletes object, overlay, event of tile
function Map:delObj(x, y)
    local tile = self:getTile(x, y)
    if tile then
        tile.object = nil
        tile.overlay = nil
        tile.event = nil
    end
end


function Map:removeEntity(x, y)
    local tile = self:getTile(x, y)
    if tile then
        self.entities[tile.npc] = nil
        tile.npc = nil
        self:sortEntities()
    end
end


-- delete all occurences of given npc on this map
function Map:deleteNpc(id)
    for x,blockrow in pairs(self.blocks) do
        for y,block in pairs(blockrow) do
            for i,row in pairs(block.tiles) do
                for j,tile in pairs(row) do
                    if tile.npc and tile.npc == id then
                        tile.npc = nil
                    end
                end
            end
        end
    end
    self.entities[id] = nil
end


function Map:addEntity(x, y, id)
    local tile = self:getTile(x, y)
    if tile and not tile.npc then
        self:deleteNpc(id)
        tile.npc = id
        self.entities[id] = entityHandler.get(id)
        self:sortEntities()
    end
end


local function compareEntities(a, b)
    return a.pos.y < b.pos.y
end


function Map:sortEntities()
    local t = {}
    for i,ent in pairs(self.entities) do
        table.insert(t, ent)
    end
    table.sort(t, compareEntities)
    self.sortedEntities = t
end


-- return a list of all entities currently on the map
function Map:loadEntities()
    local entities = {}
    for x,blockrow in pairs(self.blocks) do
        for y,block in pairs(blockrow) do
            for i,row in pairs(block.tiles) do
                for j,tile in pairs(row) do
                    if tile.npc then
                        local npc = entityHandler.get(tile.npc)
                        if npc then 
                            entities[tile.npc] = npc
                            entities[tile.npc]:place(x * C_BLOCK_SIZE + i, y * C_BLOCK_SIZE + j, true)
                        end
                    end
                end
            end
        end
    end
    self.entities = entities
    self:sortEntities()
end

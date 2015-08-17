-- Creates a single tileset out of all used ones and 
-- creates a mapping file

tilesetPacker = {}

local count = 0
local mapping = nil

-- add texture to mapping if new
function tilesetPacker.addTexture(entry)
    local ta = entry[1]
    local tx = entry[2]
    local ty = entry[3]
    if ta and tx and ty then
        if not mapping[ta] then mapping[ta] = {} end
        if not mapping[ta][tx] then mapping[ta][tx] = {} end
        if not mapping[ta][tx][ty] then
            mapping[ta][tx][ty] = true
            count = count + 1
        end
    else
        log:msg("error", "texture packer: Invalid texture:", entry)
    end
end


-- create game atlas (contains only actually used textures)
function tilesetPacker.create()
    
    -- get atlanti image data
    local imgData = {}
    for i,atlas in ipairs(tilesetreader:getAtlanti()) do
        imgData[i] = atlas.img:getData()
    end
    
    -- calculate texture size. needs to be 2^n to support old chipsets
    local n = 2
    while n * n < count do
        n = n * 2
    end
    
    -- create mapping file
    local file = love.filesystem.newFile( C_MAP_MASTER..C_MAP_GAME_ATLAS_MAPPING )
    file:open("w")
    
    -- copy all textures to game atlas
    local c_tx = 0
    local c_ty = 0
    local texture = love.image.newImageData(n * C_TILE_SIZE, n * C_TILE_SIZE)
    
    for ta,row in pairs(mapping) do
        for tx,row2 in pairs(row) do
            for ty,bool in pairs(row2) do
                
                -- copy texture
                texture:paste( imgData[ta], c_tx * C_TILE_SIZE, c_ty * C_TILE_SIZE, tx * C_TILE_SIZE, ty * C_TILE_SIZE, C_TILE_SIZE, C_TILE_SIZE )
                
                --update mapping
                file:write( tostring(ta)..','..tostring(tx)..','..tostring(ty)..'='..tostring(c_tx)..','..tostring(c_ty) .. '\n')
                mapping[ta][tx][ty] = { c_tx, c_ty }
                
                -- update texture position
                c_tx = c_tx + 1
                if c_tx >= n then
                    c_tx = 0
                    c_ty = c_ty + 1
                end
            end
        end
    end
    
    -- create game atlas files
    texture:encode( C_MAP_MASTER..C_MAP_GAME_ATLAS )
    file:close()
end


function tilesetPacker.read(path)
    local file = love.filesystem.newFile(path)
    local map = {}
    for line in file:lines() do
        local v = line:split('=')
        local l = v[1]:split(',')
        local r = v[2]:split(',')
        local ta = tonumber(l[1])
        local tx = tonumber(l[2])
        local ty = tonumber(l[3])
        if not map[ta] then map[ta] = {} end
        if not map[ta][tx] then map[ta][tx] = {} end
        map[ta][tx][ty] = { tonumber(r[1]), tonumber(r[2]) }
    end
    return map
end


-- create texture mapping
function tilesetPacker.pack()
    st_edit:reloadMapIndex()
    mapping = {}
    count = 0
    for name,map in pairs(st_edit.maps) do
        for i,row in pairs(map.blocks) do
            for j,entry in pairs(row) do
                for x = 0, C_BLOCK_SIZE - 1 do
                    for y = 0, C_BLOCK_SIZE - 1 do
                        
                        local tile = entry.tiles[x][y]
                        if tile.floor then tilesetPacker.addTexture(tile.floor) end
                        if tile.floor2 then tilesetPacker.addTexture(tile.floor2) end
                        if tile.object then tilesetPacker.addTexture(tile.object) end
                        if tile.overlay then tilesetPacker.addTexture(tile.overlay) end
                        
                    end
                end
            end
        end
    end
    tilesetPacker.create()
end
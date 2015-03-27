--[[--

    Handles all tilesets
    
    Individual tilesets are identified by hashing name and filesize
    
--]]--

tilesetreader = {}


local sets = {}


-- discover all tilesets and index them
function tilesetreader:read()
    
    sets = {}
    
    local entities = love.filesystem.getDirectoryItems(C_FOLDER_TILES)

    for k, ent in ipairs(entities) do
        
        -- only accept png files for now
        if ent:sub(-4) == ".png" then
            table.insert(sets, TexAtlas(C_FOLDER_TILES .. ent))
        end
        
    end
    
    return sets
end


function tilesetreader:getAtlanti()
    return sets
end
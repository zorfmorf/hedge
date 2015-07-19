
maploader = {}


function maploader:read( path, name )
    
    log:msg("verbose", "Loading map", path..name)
    
    local map = Map(name:sub(1, name:len() - C_MAP_SUFFIX:len()))
    
    if love.filesystem.isFile( path..name ) then
    
        local file = love.filesystem.newFile( path..name )
        file:open( "r" )
        
        local bx, by = nil
        local linex = 0
        
        for line in file:lines( ) do
            if line:sub(1, 8) == "# Tiles" then
            
            elseif line:sub(1, 8) == "# Block " then 
                bx, by = line:sub(9):match("([^,]+) ([^,]+)")
                bx = tonumber(bx)
                by = tonumber(by)
                linex = -1
            else
                local y = 0
                for i,entry in ipairs(line:split(";")) do
                    if entry:len() > 0 then
                        local params = {}
                        for k,value in ipairs(entry:split("|")) do
                            if value == "nil" then 
                                params[k] = nil
                            elseif value:len() == 1 then
                                params[k] = tonumber(value)
                            else
                                params[k] = {}
                                for l,number in ipairs(value:split(",")) do
                                    table.insert(params[k], tonumber(number))
                                end
                            end
                        end
                        map:setTile(bx * C_BLOCK_SIZE + linex, 
                            by * C_BLOCK_SIZE + y, params[1], params[2], params[3], params[4] == 1, params[5])
                    end
                    y = y + 1
                end
            end
            linex = linex + 1
        end
        
        file:close()
    else
        log:msg("debug", "Map not found:", path..name)
        map:createBlock(0, 0)
    end
    return map
end


-- save map to file
-- path needs trailing /
function maploader:save(map, path)
    
    -- target path handling
    local ok = love.filesystem.createDirectory( path )
    if not ok then log:msg("verbose", "Error creating folder", path) end
    log:msg("verbose", "Writing map", map.name, "to path", path..map.name..C_MAP_SUFFIX)
    local file = love.filesystem.newFile( path..map.name..C_MAP_SUFFIX )
    local okay, err = file:open( "w" )
    if not okay then log:msg("error", "Error saving map", map.name, "to", path, "-", err) end
    
    -- writing file content
    file:write( "# Tiles\n" )
    local blkcntr = 0
    for i, row in pairs(map.blocks) do
        for j,entry in pairs(row) do
            file:write( "# Block " .. i .. " " .. j .. "\n" )
            blkcntr = blkcntr + 1
            for x = 0, C_BLOCK_SIZE - 1 do
                for y = 0, C_BLOCK_SIZE - 1 do
                    
                    local block = entry.tiles[x][y]
                    
                    -- floor tiles
                    if block.floor then 
                        file:write( block.floor[1] .."," )
                        file:write( block.floor[2] .."," )
                        file:write( block.floor[3] )
                    else
                        file:write( "nil" )
                    end
                    file:write( "|" )
                    
                    -- object tiles
                    if block.object then 
                        file:write( block.object[1] .."," )
                        file:write( block.object[2] .."," )
                        file:write( block.object[3] )
                    else
                        file:write( "nil" )
                    end
                    file:write( "|" )
                    
                    -- overlay tiles
                    if block.overlay then 
                        file:write( block.overlay[1] .."," )
                        file:write( block.overlay[2] .."," )
                        file:write( block.overlay[3] )
                    else
                        file:write( "nil" )
                    end
                    file:write( "|" )
                    
                    -- walkable
                    if block.block then 
                        file:write( 1 )
                    else
                        file:write( 0 )
                    end
                    file:write( "|" )
                    
                    -- event number
                    if block.event then
                        file:write( block.event )
                    else
                        file:write( "nil" )
                    end
                    
                    file:write( ";" )
                end
                file:write( "\n" )
            end
        end
    end
    local result = file:close( )
    log:msg("verbose", "Wrote", blkcntr, "blocks to", love.filesystem.getRealDirectory( path ).."/"..path )
end

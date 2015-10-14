
maploader = {}


function maploader:read( path, name )
    
    log:msg("verbose", "Loading map", path..name)
    
    local map = Map(name:sub(1, name:len() - C_MAP_SUFFIX:len()))
    
    local animations = {} -- npc directions can be temporarily saved here
    
    if love.filesystem.isFile( path..name ) then
    
        local file = love.filesystem.newFile( path..name )
        file:open( "r" )
        
        local bx, by = nil
        local linex = 0
        
        local readspawns = false
        local readsettings = false
        
        for line in file:lines( ) do
            if line:sub(1, 8) == "# Tiles" then
                readsettings = false
            elseif line:sub(1, 10) == "# Settings" then
                readsettings = true
            elseif line:sub(1, 8) == "# Spawns" then
                readspawns = true
            elseif line:sub(1, 8) == "# Block " then 
                bx, by = line:sub(9):match("([^,]+) ([^,]+)")
                bx = tonumber(bx)
                by = tonumber(by)
                linex = -1
            elseif readsettings then
                local values = line:split(";")
                if tonumber(values[1]) then values[1] = tonumber(values[1]) end
                if tonumber(values[2]) then values[2] = tonumber(values[2]) end
                if values[2] == "true" then values[2] = true end
                map:setSetting(values[1], values[2])
            elseif readspawns then
                log:msg("verbose", "Found spawn at", line)
                local values = line:split(";")
                if values then
                    map.spawns[tonumber(values[1])] = { x=tonumber(values[2]), y=tonumber(values[3]) }
                end
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
                                    if tonumber(number) then
                                        table.insert(params[k], tonumber(number))
                                    else
                                        table.insert(params[k], number)
                                    end
                                end
                                -- if we read an npc settings we need to handle the direction extra
                                if k == 7 and params[7][1] and params[7][2] then
                                    animations[params[7][1]] = params[7][2]
                                    params[7] = params[7][1]
                                end
                            end
                        end
                        map:setTile(bx * C_BLOCK_SIZE + linex, 
                            by * C_BLOCK_SIZE + y, params[1], params[2], params[3], params[4], params[5] == 1, params[6], params[7])
                    end
                    y = y + 1
                end
            end
            linex = linex + 1
        end
        
        file:close()
        log:msg("verbose", "Finished loading map", map.name)
    else
        log:msg("debug", "Map not found:", path..name)
        map:createBlock(0, 0)
    end
    
    -- load up entities and set their directions
    map:loadEntities()
    for npc,dir in pairs(animations) do
        if map.entities[npc] then map.entities[npc].dir = dir end
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
    
    -- writing settings
    file:write( "# Settings\n" )
    for key,value in pairs(map.settings) do
        file:write( tostring(key) .. ";" .. tostring(value) .. "\n" )
    end
    
    -- writing file content
    file:write( "# Tiles\n" )
    local blkcntr = 0
    for i,row in pairs(map.blocks) do
        for j,entry in pairs(row) do
            file:write( "# Block " .. i .. " " .. j .. "\n" )
            blkcntr = blkcntr + 1
            for x = 0, C_BLOCK_SIZE - 1 do
                for y = 0, C_BLOCK_SIZE - 1 do
                    
                    local tile = entry.tiles[x][y]
                    
                    -- floor tiles
                    if tile.floor then 
                        file:write( tile.floor[1] .."," )
                        file:write( tile.floor[2] .."," )
                        file:write( tile.floor[3] )
                    else
                        file:write( "nil" )
                    end
                    file:write( "|" )
                    
                    -- floor2 tiles
                    if tile.floor2 then 
                        file:write( tile.floor2[1] .."," )
                        file:write( tile.floor2[2] .."," )
                        file:write( tile.floor2[3] )
                    else
                        file:write( "nil" )
                    end
                    file:write( "|" )
                    
                    -- object tiles
                    if tile.object then 
                        file:write( tile.object[1] .."," )
                        file:write( tile.object[2] .."," )
                        file:write( tile.object[3] )
                    else
                        file:write( "nil" )
                    end
                    file:write( "|" )
                    
                    -- overlay tiles
                    if tile.overlay then 
                        file:write( tile.overlay[1] .."," )
                        file:write( tile.overlay[2] .."," )
                        file:write( tile.overlay[3] )
                    else
                        file:write( "nil" )
                    end
                    file:write( "|" )
                    
                    -- walkable
                    if tile.block then 
                        file:write( 1 )
                    else
                        file:write( 0 )
                    end
                    file:write( "|" )
                    
                    -- event number
                    if tile.event then
                        if type(tile.event) == "table" then
                            file:write( tile.event[1]..','..tostring(tile.event[2]) )
                        else
                            file:write( tile.event )
                        end
                    else
                        file:write( "nil" )
                    end
                    file:write( "|" )
                    
                    -- npc number
                    if tile.npc and map.entities[tile.npc] then
                        file:write( tile.npc..","..map.entities[tile.npc].dir )
                    else
                        file:write( "nil" )
                    end
                    
                    file:write( ";" )
                end
                file:write( "\n" )
            end
        end
    end
    file:write( "# Spawns\n" )
    for i,value in pairs(map.spawns) do
        file:write( i..";"..value.x..";"..value.y.."\n")
    end
    local result = file:close( )
    log:msg("verbose", "Wrote", blkcntr, "blocks to", love.filesystem.getRealDirectory( path ).."/"..path )
end

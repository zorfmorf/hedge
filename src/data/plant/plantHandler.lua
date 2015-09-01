
plantHandler = {}


function plantHandler.load()
    game.plants = {}
    if love.filesystem.isFile( C_MAP_CURRENT..C_MAP_PLANTS )then
        local file = love.filesystem.newFile( C_MAP_CURRENT..C_MAP_PLANTS )
        file:open("r")
        for line in file:lines( ) do
            local values = line:split(";")
            if #values == 6 then
                local plant = nil
                if values[1] == "Potatoe" then plant = Potatoe() end
                plant.map = values[2]
                plant.tx = tonumber(values[3])
                plant.ty = tonumber(values[4])
                plant.days = tonumber(values[5])
                plant.state = tonumber(values[6])
                table.insert(game.plants, plant)
            end
        end
        file:close()
    end
end


function plantHandler.save()
    local file = love.filesystem.newFile( C_MAP_CURRENT..C_MAP_PLANTS )
    if file then 
        file:open("w")
        for i,plant in pairs(game.plants) do
            file:write(plant.type..';')
            file:write(plant.map..';')
            file:write(tostring(plant.tx)..';')
            file:write(tostring(plant.ty)..';')
            file:write(tostring(plant.days)..';')
            file:write(tostring(plant.state)..'\n')
        end
        file:close()
    else
        log:msg("error", "Failed to create file", C_MAP_PLANTS)
    end
end

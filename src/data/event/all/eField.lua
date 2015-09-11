-- a big stone on the field

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    local tile = game.map:getTile(tx, ty)
    
    -- plow field
    if tile.plowed then
        if tile.plantable and not tile.object then
            local tool = inventory:getTool()
            if tool and tool.id == "Seedbag" then
                local seed = tool:use()
                if seed then
                    if seed == "Potatoes"  then table.insert(game.plants, Plant_Potatoe(tx, ty)) end
                    if seed == "Corn"  then table.insert(game.plants, Plant_Wheat(tx, ty)) end
                    tile.event = 5 -- ePlant
                end
            end
        end
    else
        if inventory:usesTool("Shovel") then
            tile.floor = deepcopy(texture["field.patch"])
            tile.plowed = true
            mapHelper:plowedFieldTile(tx, ty)
            inventory:usedCurrentTool(2)
            timeHandler.addTime(20)
        end
    end
end


return {
        id = 4,
        init = init,
        use = use,
        walk = walk
    }
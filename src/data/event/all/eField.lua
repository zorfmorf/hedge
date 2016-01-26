-- a big stone on the field

local function init()
    
end


local function walk(tx, ty)
    
end


local function fieldEvent(tx, ty)
    local tile = game.map:getTile(tx, ty)
    
    -- plow field
    if tile.plowed then
        if tile.plantable and not tile.object then
            local tool = inventory:getTool()
            if tool and tool.id == "Seedbag" then
                local seed = tool:use()
                if seed then
                    if seed == "Potatoes" then table.insert(game.plants, Plant_Potatoe(tx, ty)) end
                    if seed == "Corn" then table.insert(game.plants, Plant_Wheat(tx, ty)) end
                    if seed == "Cucumber seeds" then table.insert(game.plants, Plant_Cucumber(tx, ty)) end
                    if seed == "Carrot seeds" then table.insert(game.plants, Plant_Carrot(tx, ty)) end
                    if seed == "Cabbage seeds" then table.insert(game.plants, Plant_Cabbage(tx, ty)) end
                    tile.event = 5 -- ePlant
                    timeHandler.addTime(tool:getCycles() * C_WORK_UNIT)
                end
            end
        end
    else
        if inventory:usesTool("Spade") then
            local tool = inventory:getTool()
            tile.floor = deepcopy(texture["field.patch"])
            tile.plowed = true
            mapHelper:plowedFieldTile(tx, ty)
            timeHandler.addTime(tool:getCycles() * C_WORK_UNIT)
        end
    end
end

local function use(tx, ty)
    local tile = game.map:getTile(tx, ty)
    if tile.plowed then
        if tile.plantable and not tile.object then
            local tool = inventory:getTool()
            if tool and tool.id == "Seedbag" and tool.seed then
                player.animation = { timer=0, tx=tx, ty=ty, use=fieldEvent, cycles=tool:getCycles(), handsFree=true }
            end
        end
    else
        if inventory:usesTool("Spade") then
            local tool = inventory:getTool()
            player.animation = { timer=0, tx=tx, ty=ty, use=fieldEvent, cycles=tool:getCycles() }
        end
    end
end


return {
        init = init,
        use = use,
        walk = walk
    }
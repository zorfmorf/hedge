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
            table.insert(game.plants, Potatoe(tx, ty))
            tile.event = 5 -- ePlant
        end
    else
        if inventory:usesTool("Shovel") then
            tile.floor = deepcopy(texture["field.patch"])
            tile.plowed = true
            mapHelper:plowedFieldTile(tx, ty)
            inventory:usedCurrentTool()
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
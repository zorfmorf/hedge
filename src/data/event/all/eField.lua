-- a big stone on the field

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    local tile = game.map:getTile(tx, ty)
    
    -- plow field
    if tile.plowed then
    
    else --TODO if correct tool equipped        
        tile.floor = deepcopy(texture["field.patch"])
        tile.plowed = true
        mapHelper:plowedFieldTile(tx, ty)
    end
end


return {
        id = 4,
        init = init,
        use = use,
        walk = walk
    }
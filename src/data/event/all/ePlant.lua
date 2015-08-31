-- handle plants on a field

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    local tile = game.map:getTile(tx, ty)
    for i,plant in pairs(game.plants) do
        if plant.map == game.map.name and plant.tx == tx and plant.ty == ty then
            if plant:isHarvestable() then
                log:msg("verbose", "Harvesting", plant.type, "at", tx, ty)
                plant:harvest()
                plant:update()
            end
        end
    end
end


return {
        id = 5,
        init = init,
        use = use,
        walk = walk
    }
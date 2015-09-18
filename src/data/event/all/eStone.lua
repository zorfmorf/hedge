-- a big stone on the field

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    local tile = game.map:getTile(tx, ty)
    
    if tile and inventory:hasFreeSlots() then
        if inventory:usesTool("Pickaxe") then
            -- update tile
            tile.object = nil
            tile.block = false
            tile.event = 4 -- field event
            
            -- game logic
            inventory:add(itemCreator:getStone(1))
            timeHandler.addTime(60)
            inventory:usedCurrentTool()
        end
    end
end


return {
        id = 1,
        init = init,
        use = use,
        walk = walk
    }
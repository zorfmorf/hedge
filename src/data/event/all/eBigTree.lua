-- a big tree on the field

local function init()
    
end


local function walk(tx, ty)
    
end


local function chopDownTreeEvent(tx, ty)
    local tile = game.map:getTile(tx, ty)
    
    -- update tree tile
    tile.object = nil
    tile.overlay = nil
    tile.block = false
    tile.event = 4 -- field event
    
    -- update surrounding tiles
    for x=-1,1 do
        for y=-3,1 do
            if not (x == 0 and y == 0) then
                tile = game.map:getTile(tx+x, ty+y)
                if tile then
                    tile.overlay = nil
                    tile.event = 4
                    if y >= 0 then tile.object = nil end
                end
            end
        end
    end
    
    -- game logic
    local tool = inventory:getTool()
    inventory:add(itemCreator:getWood(3))
    timeHandler.addTime(tool:getCycles() * C_WORK_UNIT * 3)
end


local function use(tx, ty)
    local tile = game.map:getTile(tx, ty)
    
    if inventory:usesTool("Axe") then
        if tile and inventory:hasFreeSlots(3) then
            local tool = inventory:getTool()
            player.animation = { timer=0, tx=tx, ty=ty, use=chopDownTreeEvent, cycles=tool:getCycles() }
        end
    else
        player:addFloatingText(message.noAxe, true)
    end
end


return {
        id = 9,
        init = init,
        use = use,
        walk = walk
    }
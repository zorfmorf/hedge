-- a big stone on the field

local function init()
    
end


local function walk(tx, ty)
    
end


local function stoneEvent(tx, ty)
    
    local tile = game.map:getTile(tx, ty)
    
    -- update tile
    tile.object = nil
    tile.block = false
    tile.event = 4 -- field event
    
    -- game logic
    local tool = inventory:getTool()
    inventory:add(itemCreator:getStone(1))
    timeHandler.addTime(tool:getCycles() * C_WORK_UNIT * 3)
end


local function use(tx, ty)
    local tile = game.map:getTile(tx, ty)
    
    if inventory:usesTool("Pickaxe") then
        if tile and inventory:hasFreeSlots() then
            local tool = inventory:getTool()
            player.animation = { timer=0, tx=tx, ty=ty, use=stoneEvent, cycles=tool:getCycles() }
        end
    else
        player:addFloatingText(message.noPick, true)
    end
end


return {
        init = init,
        use = use,
        walk = walk
    }
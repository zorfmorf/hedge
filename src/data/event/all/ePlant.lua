-- handle plants on a field

local function init()
    
end


local function walk(tx, ty)
    
end


local function plantEvent(tx, ty)
    local tile = game.map:getTile(tx, ty)
    for i,plant in pairs(game.plants) do
        if plant.map == game.map.name and plant.tx == tx and plant.ty == ty then
            if plant:isHarvested() and inventory:usesTool("Shovel") then
                tile.block = false
                tile.object = nil
                tile.plantable = true
                tile.event = 4 -- eField
                table.remove(game.plants, i)
                return
            end
            if plant:isHarvestable() then
                log:msg("verbose", "Harvesting", plant.type, "at", tx, ty)
                if plant.type == "Wheat" then
                    if inventory:usesTool("Scythe") and inventory:hasFreeSlots() then
                        local amount = 1
                        plant:harvest()
                        for i,cand in ipairs(game.plants) do
                            if game.map.name == cand.map and
                               ((plant.tx == player.pos.x and plant.ty == cand.ty and math.abs(plant.tx - cand.tx) == 1) or
                                (plant.ty == player.pos.y and plant.tx == cand.tx and math.abs(plant.ty - cand.ty) == 1)) then
                                cand:harvest()
                                amount = amount + 1
                            end
                        end
                        inventory:add(itemCreator:getWheat(amount))
                    end
                else
                    if inventory:hasFreeSlots() then
                        plant:harvest()
                    end
                end
            end
        end
    end
end


local function use(tx, ty)
    local tile = game.map:getTile(tx, ty)
    for i,plant in pairs(game.plants) do
        if plant.map == game.map.name and plant.tx == tx and plant.ty == ty then
            if plant:isHarvested() and inventory:usesTool("Shovel") then
                local tool = inventory:getTool()
                timeHandler.addTime(tool:getCycles() * C_WORK_UNIT)
                player.animation = { timer=0, tx=tx, ty=ty, use=plantEvent, cycles=tool:getCycles() }
            end
            if plant:isHarvestable() then
                if plant.type == "Wheat" then
                    if inventory:usesTool("Scythe") and inventory:hasFreeSlots() then
                        local tool = inventory:getTool()
                        timeHandler.addTime(tool:getCycles() * C_WORK_UNIT)
                        player.animation = { timer=0, tx=tx, ty=ty, use=plantEvent, cycles=tool:getCycles() }
                    end
                else
                    if inventory:hasFreeSlots() then
                        timeHandler.addTime(C_WORK_UNIT)
                        player.animation = { timer=0, tx=tx, ty=ty, use=plantEvent, cycles=1 }
                    end
                end
            end
            return
        end
    end
end


return {
        id = 5,
        init = init,
        use = use,
        walk = walk
    }

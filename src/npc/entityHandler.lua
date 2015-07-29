
entityHandler = {}

local entities = {}


function entityHandler.load()
    -- TODO, load entities from file
    entities = {}
    entities[1] = Player()
    player = entities[1]
    entities[2] = Npc(2)
    entities[3] = Npc(3)
    entities[4] = Npc(4)
end


function entityHandler.save()
    -- TODO. Save all entites to file
end


function entityHandler.get(id)
    if not entities[id] then log:msg("debug", "Unkown entity requested:", id) end
    return entities[id]
end


function entityHandler.getAll()
    return entities
end

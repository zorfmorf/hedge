
entityHandler = {}

local entities = {}


function entityHandler.load()
    entities = {}
    player = Player()
    entities[1] = player
    
    local dir = "data/entity/all/"
    local files = love.filesystem.getDirectoryItems(dir)

    for k, ents in ipairs(files) do
        local name = string.gsub( ents, ".lua", "")
        local data = require(dir .. "/" .. name)
        if data.id and data.name then
            if not entities[data.id] then
                local npc = Npc(data.id)
                npc.name = data.name
                entities[npc.id] = npc
                if data.use then npc.use = data.use end
                if data.charset then npc.charset = data.charset end
                if data.ai then npc.ai = data.ai end
                log:msg("verbose", "Read npc: ", entities[npc.id].id, entities[npc.id].name)
            else
                log:msg("error", "Loaded npc exists for id", data.id, ":", data.name, " was read, but conflicts with existing npc", entities[npc.id].name)
            end
        else
            log:msg("error", "Loading npc error:", name, "id:", data.id, "name:", data.name)
        end
    end
end


function entityHandler.get(id)
    if not entities[id] then log:msg("debug", "Unkown entity requested:", id) end
    return entities[id]
end


function entityHandler.getAll()
    return entities
end

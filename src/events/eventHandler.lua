-- can load and save all events

eventHandler = {}

local events = nil

local function loadEvents()
    local dir = "events/event"
    local entities = love.filesystem.getDirectoryItems(dir)

    for k, ents in ipairs(entities) do
        local name = string.gsub( ents, ".lua", "")
        local event = require(dir .. "/" .. name)
        if not events[event.id] then
            event.name = name
            event.init()
            events[event.id] = event
            log:msg("verbose", "Read event: "..event.id..", "..event.name)
        else
            log:msg("error", "Loading event error, id exists: "..event.id)
        end
    end
end


function eventHandler:init()
    events = {}
    loadEvents()
end


function eventHandler:getEvents()
    return events
end


function eventHandler.walkedOnTile(pos)
    local tile = game.map:getTile(pos.x, pos.y)
    if tile and tile.event and events[tile.event] then
        log:msg("verbose", "Walked on event", events[tile.event].name)
        events[tile.event].walk(x, y)
    end
end

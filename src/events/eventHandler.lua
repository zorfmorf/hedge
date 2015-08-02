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


-- !!! use this only for use events, not for walking events !!!
-- there is a separate walkedOnTile function
function eventHandler.triggerEvent(id, walked)
    if events[id] then
        log:msg("verbose", "Triggered event", events[id].name)
        if walked then
            events[id].walk()
        else
            events[id].use()
        end
    end
end


function eventHandler.walkedOnTile(pos)
    local tile = game.map:getTile(pos.x, pos.y)
    if tile and tile.event then
        if type(tile.event) == "table" then
            log:msg("verbose", "Triggered transition to", tile.event[1]..":"..tile.event[2])
            st_ingame.transition = Transition("fade_out", function()
                        game.map = maploader:read(C_MAP_CURRENT, tile.event[1]..C_MAP_SUFFIX)
                        st_ingame:placePlayer(tile.event[2])
                    end)
            return true
        else
            eventHandler.triggerEvent(tile.event, true)
            return false
        end
    end
    return false
end

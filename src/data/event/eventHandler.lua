-- can load and save all events

eventHandler = {}

local events = nil

local function loadEvents()
    local dir = "data/event/all"
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
function eventHandler.triggerEvent(id, walked, tx, ty)
    if events[id] then
        log:msg("verbose", "Triggered event", events[id].name, "at", tx, ty)
        if walked then
            events[id].walk(tx, ty)
        else
            events[id].use(tx, ty)
        end
    end
end


function eventHandler.walkedOnTile(pos)
    local tile = game.map:getTile(pos.x, pos.y)
    if tile and tile.event then
        if type(tile.event) == "table" then
            log:msg("verbose", "Triggered transition to", tile.event[1]..":"..tile.event[2])
            st_ingame.transition = Transition("fade_out", function()
                        maploader:save(game.map, C_MAP_CURRENT)
                        game.map = maploader:read(C_MAP_CURRENT, tile.event[1]..C_MAP_SUFFIX)
                        st_ingame:placePlayer(tile.event[2])
                        game:updatePlants()
                    end)
            return true
        else
            eventHandler.triggerEvent(tile.event, true, pos.x, pos.y)
        end
    end
    return false
end

-- can load and save all events

eventHandler = {}

local events = nil

local function loadEvents()
    local dir = "data/event/all"
    local entities = love.filesystem.getDirectoryItems(dir)

    for k, ents in ipairs(entities) do
        local name = string.gsub( ents, ".lua", "")
        local event = require(dir .. "/" .. name)
        event.name = name
        if not events[event.name] then
            event.init()
            events[event.name] = event
            log:msg("verbose", "Read event: "..event.name)
        else
            log:msg("error", "Loading event error, name already exists: "..event.name)
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
-- this is necessary to seperate the map change events, this method only
-- handles actual events, not transition events
function eventHandler.triggerEvent(id, walked, tx, ty)
    if events[id] then
        log:msg("verbose", "Triggered event", events[id].name, "at", tx, ty, "walked =", walked)
        if walked then
            events[id].walk(tx, ty)
        else
            events[id].use(tx, ty)
        end
    else
        log:msg("error", "eventHandler - event not found:", "id="..id, "walked="..walked, "tx="..tx, "ty="..ty)
    end
end


function eventHandler.walkedOnTile(pos)
    local tile = game.map:getTile(pos.x, pos.y)
    if tile and tile.event then
        if type(tile.event) == "table" then
            log:msg("verbose", "Triggered transition to", tile.event[1]..":"..tile.event[2])
            st_ingame.transition = Transition("fade_out", function()
                        saveHandler.saveGame("auto")
                        local applyTime = game.map:getSetting("transition_time")
                        game.map = maploader:read(C_MAP_CURRENT, tile.event[1]..C_MAP_SUFFIX)
                        st_ingame:placePlayer(tile.event[2])
                        if applyTime and game.map:getSetting("transition_time") then
                          timeHandler.addTime(C_TRANSITION_TIME)
                        end
                        game:updatePlants()
                    end)
            return true
        else
            eventHandler.triggerEvent(tile.event, true, pos.x, pos.y)
        end
    end
    return false
end

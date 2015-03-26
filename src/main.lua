
-- require libraries
Gamestate = require "lib.hump.gamestate"
Class = require "lib.hump.class"
Gui = require "lib.quickie"

-- require everything in the given subdirectory
local function requireDirectory( dir )
    dir = dir or ""
    local entities = love.filesystem.getDirectoryItems(dir)

    for k, ents in ipairs(entities) do
        trim = string.gsub( ents, ".lua", "")
        require(dir .. "/" .. trim)
    end
end


requireDirectory( 'state' )
requireDirectory( 'misc' )
requireDirectory( 'map' )
    

-- load hook. executed once on startup
function love.load()
    Gamestate.registerEvents()
    --Gamestate.switch(st_menu_main)
    Gamestate.switch(st_edit)
end


-- draw hook
function love.draw()
    -- contains nothing -> draw operations are found in state files
end


-- catches keyboard events
function love.keypressed(key, isrepeat)
    if key == "escape" then
        love.event.push("quit")
    end
end

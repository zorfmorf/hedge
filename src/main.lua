
-- require libraries
Gamestate = require "lib.hump.gamestate"
Class = require "hump.class"

-- load helper
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
requireDirectory( 'class' )
    

-- load hook. executed once on startup
function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(st_menu_main)
end


-- draw hook
function love.draw()
    love.graphics.rectangle("line", 20, 20, 100, 100)
end


-- catches keyboard events
function love.keypressed(key, isrepeat)
    if key == "escape" then
        love.event.push("quit")
    end
end

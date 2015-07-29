
-- require libraries
Gamestate = require "lib.hump.gamestate"
Class = require "lib.hump.class"
Gui = require "lib.quickie"
Camera = require "lib.hump.camera"
Color = require "misc.color"

-- require everything in the given subdirectory
local function requireDirectory( dir )
    dir = dir or ""
    local entities = love.filesystem.getDirectoryItems(dir)

    for k, ents in ipairs(entities) do
        local trim = string.gsub( ents, ".lua", "")
        require(dir .. "/" .. trim)
    end
end


requireDirectory( 'state' )
requireDirectory( 'misc' )
requireDirectory( 'map' )
requireDirectory( 'class' )
require "events.eventHandler" -- dont require the events itself
require "npc.entityHandler" -- dont require the actual npcs itself


-- load hook. executed once on startup
function love.load()
    log.init()
    Gamestate.registerEvents()
    Gamestate.switch(st_menu_main)
    --Gamestate.switch(st_edit)
end


-- draw hook
function love.draw()
    -- contains nothing -> draw operations are found in state files
end


-- catches keyboard events
function love.keypressed(key, isrepeat)
    Gui.keyboard.pressed(key)
end


function love.textinput(str)
    Gui.keyboard.textinput(str)
end

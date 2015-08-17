
-- require libraries
Gamestate = require "lib.hump.gamestate"
Class = require "lib.hump.class"
Gui = require "lib.quickie"
Camera = require "lib.hump.camera"

-- require everything in the given subdirectory
local function requireDirectory( dir )
    dir = dir or ""
    local entities = love.filesystem.getDirectoryItems(dir)

    for k, ent in ipairs(entities) do
        if love.filesystem.isFile(dir.."/"..ent) then
            local trim = string.gsub( ent, ".lua", "")
            require(dir .. "/" .. trim)
        end
    end
end

requireDirectory( 'misc' )
requireDirectory( 'data' )
requireDirectory( 'data/dialog' )
requireDirectory( 'data/entity' )
requireDirectory( 'data/event' )
requireDirectory( 'data/map' )
requireDirectory( 'data/texture' )
requireDirectory( 'editor' )
requireDirectory( 'game' )
requireDirectory( 'view' )
requireDirectory( 'state' )


-- load hook. executed once on startup
function love.load()
    -- DEBUG
    --if arg[#arg] == "-debug" then require("mobdebug").start() end
    
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

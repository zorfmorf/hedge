
local saveslots = nil
local showLoad = false

st_menu_main = {}

function st_menu_main:enter()
    
    Gui.group.default.spacing = 5
    
    saveslots = nil
    local files = love.filesystem.getDirectoryItems(C_MAP_SAVEGAMES)
    if files then
        for i,file in pairs(files) do
            if love.filesystem.isDirectory( C_MAP_SAVEGAMES..file ) then
                if not saveslots then saveslots = {} end
                saveslots[file] = true
            end
        end
    end
    
end


local function loadMenu()
    for slot,bool in pairs(saveslots) do
        if Gui.Button{text = slot} then
            showLoad = false
            saveHandler.loadGame(slot)
            Gamestate.switch(st_ingame)
        end
    end
end


function st_menu_main:update(dt)
    
    screen:update()
    
    Gui.group.push{grow = "down", pos = {screen.w * 0.2, screen.h * 0.4}}
    
        if showLoad then 
            loadMenu()
        else
            if Gui.Button{text = "Play"} then 
                saveHandler.newGame()
                Gamestate.switch(st_ingame)
            end
            if saveslots then 
                if Gui.Button{text = "Load"} then
                    showLoad = true
                end
            end
            if C_DEBUG and Gui.Button{text = "Editor"} then Gamestate.switch(st_edit) end
            Gui.Button{text = "Options"}
            if Gui.Button{text = "Exit"} then love.event.push("quit") end
        end
        
    Gui.group.pop{}
    
end


function st_menu_main:draw()
    Gui.core.draw()
end


function st_menu_main:keypressed(key, isrepeat)
    if key == "escape" then 
        if showLoad then
            showLoad = false
        else
            love.event.push("quit")
        end
    end
end
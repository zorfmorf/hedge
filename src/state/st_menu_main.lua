
local saveslots = nil
local showLoad = false
local options = false

st_menu_main = {}

function st_menu_main:enter()
    
    Gui.group.default.spacing = 5
    
    saveslots = {}
    local files = love.filesystem.getDirectoryItems(C_MAP_SAVEGAMES)
    if files then
        for i,file in pairs(files) do
            if love.filesystem.isDirectory( C_MAP_SAVEGAMES..file ) then
                local name = file
                if not (name == "auto") then name = tonumber(name) end
                saveslots[name] = true
            end
        end
    end
    
end


local function loadSlot(slot)
    showLoad = false
    saveHandler.loadGame(slot)
    Gamestate.switch(st_ingame)
end


local function loadMenu()
    if saveslots.auto and Gui.Button{text = message.autosave} then
        loadSlot("auto")
    end
    for i,bool in ipairs(saveslots) do
        if Gui.Button{text = message.saveslot..i} then
            showLoad = false
            saveHandler.loadGame(i)
            Gamestate.switch(st_ingame)
        end
    end
end


function st_menu_main:update(dt)
    
    screen:update()
    
    Gui.group.push{grow = "down", pos = {screen.w * 0.2, screen.h * 0.2}}
    
        if showLoad then 
            loadMenu()
        elseif options then
            options = settings:show()
        else
            if Gui.Button{text = "Play"} then 
                saveHandler.newGame()
                Gamestate.switch(st_intro)
            end
            if saveslots and #saveslots > 0 then 
                if Gui.Button{text = "Load"} then
                    showLoad = true
                end
            end
            if C_DEBUG and Gui.Button{text = "Editor"} then Gamestate.switch(st_edit) end
            if Gui.Button{text = "Options"} then
                options = true
                settings:read()
            end
            if Gui.Button{text = "Exit"} then
                settings:save()
                love.event.push("quit")
            end
            if C_DEBUG and Gui.Button{text = "Crash"} then
                print(makaber.schokolade.mal.abst)
            end
        end
        
    Gui.group.pop{}
    
end


function st_menu_main:draw()
    Gui.core.draw()
end


function st_menu_main:keypressed(key, scancode, isrepeat)
    if key == "escape" then 
        if showLoad then
            showLoad = false
        else
            settings:save()
            love.event.push("quit")
        end
    end
end

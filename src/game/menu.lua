local font = love.graphics.newFont(20)

Menu = Class{}


function Menu:init()
    self.current = "default"
end


function Menu:loadSave(index)
    local filepath = C_MAP_SAVEGAMES..tostring(index)
    if love.filesystem.isDirectory( filepath ) then
        local file = love.filesystem.newFile( filepath )
        if file then self.slots[index] = file end
    end
end


function Menu:readSaveFolders()
    self.slots = {}
    local files = love.filesystem.getDirectoryItems(C_MAP_SAVEGAMES)
    
    if files then
        self:loadSave("auto")
        for i=1,10 do
            self:loadSave(i)
        end
    end
end


function Menu:isOpen()
    return self.active
end


function Menu:open()
    self:readSaveFolders()
    self.active = true
    self.current = "default"
    love.mouse.setVisible(true)
end


function Menu:update(dt)
    Gui.group.push{grow = "down", pos = {screen.w * 0.2, screen.h * 0.2}}
        if self.current == "settings" then
            if not settings:show() then
                self.current = "default"
            end
        end
        if self.current == "default" then
            if Gui.Button{text = "Resume"} then 
                self.active = false
            end
            if Gui.Button{text = "Save"} then
                self.current = "save"
            end
            if Gui.Button{text = "Load"} then
                self.current = "load"
            end
            if Gui.Button{text = "Settings" } then
                self.current = "settings"
                settings:read()
            end
            if Gui.Button{text = "Exit"} then
                saveHandler.saveGame()
                Gamestate.switch(st_menu_main)
            end
        end
        if self.current == "load" then
            if self.slots.auto and Gui.Button{text = message.autosave } then
                saveHandler.loadGame("auto")
                self.active = false
                love.mouse.setVisible(false)
                st_ingame:enter()
            end
            for i,slot in ipairs(self.slots) do
                if Gui.Button{text = message.saveslot..tostring(i)} then
                    saveHandler.loadGame(i)
                    self.active = false
                    love.mouse.setVisible(false)
                    st_ingame:enter()
                end
            end
            Gui.Label{text=""}
            if Gui.Button{text = "Return"} then
                self.current = "default"
            end
        end
        if self.current == "save" then
            for i,slot in ipairs(self.slots) do
                if Gui.Button{text = message.saveslot..tostring(i)} then
                    saveHandler.saveGame(slot)
                    self.active = false
                    love.mouse.setVisible(false)
                end
            end
            if Gui.Button{text = message.newsave} then
                local slotnumber = tonumber(#self.slots)
                if not slotnumber then slotnumber = 0 end
                for i,slot in ipairs(self.slots) do
                    if slot == "auto" then slotnumber = slotnumber - 1 end
                end
                saveHandler.saveGame(tostring(slotnumber + 1))
                self.active = false
                love.mouse.setVisible(false)
            end
            Gui.Label{text=""}
            if Gui.Button{text = "Return"} then
                self.current = "default"
            end
        end
    Gui.group.pop{}
end


function Menu:draw()
    love.graphics.setColor(Color.GREY)
    love.graphics.rectangle("fill", 0, 0, screen.w, screen.h)
    love.graphics.setColor(Color.WHITE)
end


function Menu:keypressed(key, scancode, isrepeat)
    if key == "escape" then 
        if self.current == "default" then
            self.active = false
            love.mouse.setVisible(false)
        else
            self.current = "default"
        end
    end
end

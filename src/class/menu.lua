local font = love.graphics.newFont(20)

Menu = Class{}


function Menu:init()
    self.current = "default"
end


function Menu:readSaveFolders()
    self.slots = {}
    local files = love.filesystem.getDirectoryItems(C_MAP_SAVEGAMES)
    if files then
        for i,file in pairs(files) do
            if love.filesystem.isDirectory( C_MAP_SAVEGAMES..file ) then
                table.insert(self.slots, file)
            end
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
end


function Menu:update(dt)
    Gui.group.push{grow = "down", pos = {screen.w * 0.2, screen.h * 0.4}}
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
            if Gui.Button{text = "Exit"} then
                saveHandler.saveGame()
                Gamestate.switch(st_menu_main)
            end
        end
        if self.current == "load" then
            for i,slot in ipairs(self.slots) do
                if Gui.Button{text = slot} then
                    saveHandler.loadGame(slot)
                    self.active = false
                    st_ingame:enter()
                    return
                end
            end
            Gui.Label{text=""}
            if Gui.Button{text = "Return"} then
                self.current = "default"
            end
        end
        if self.current == "save" then
            for i,slot in ipairs(self.slots) do
                if not (slot == "auto") then
                        if Gui.Button{text = slot} then
                        saveHandler.saveGame(slot)
                        self.active = false
                    end
                end
            end
            if Gui.Button{text = "New"} then
                local slotnumber = tonumber(#self.slots)
                if not slotnumber then slotnumber = 0 end
                for i,slot in ipairs(self.slots) do
                    if slot == "auto" then slotnumber = slotnumber - 1 end
                end
                saveHandler.saveGame(tostring(slotnumber + 1))
                self.active = false
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


function Menu:keypressed(key, isrepeat)
    if key == "escape" then 
        if self.current == "default" then
            self.active = false
        else
            self.current = "default"
        end
    end
end

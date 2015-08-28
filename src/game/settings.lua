
settings = {}


function settings:read()
    self.settings = {}
    local w, h, f = love.window.getMode()
    self.settings.mode = f
    self.settings.width = w
    self.settings.height = h
    self.settings.modes = love.window.getFullscreenModes()
    self.settings.modeindex = 1
    self.settings.fsaa = self.settings.mode.fsaa
    table.sort(self.settings.modes, 
        function(a, b) return a.width*a.height < b.width*b.height end)
    for i,mode in pairs(self.settings.modes) do
        if mode.width == self.settings.width and mode.height == self.settings.height then
            self.settings.modeindex = i
        end
    end
end


function settings:show()
    local open = true
    Gui.group.push{ grow="down" }
    
        Gui.group.push{ grow="right" }
            Gui.Label{ text="Resolution "}
            if Gui.Button{ text=" - ", size = {'tight'} } then
                self.settings.modeindex = self.settings.modeindex - 1
                if self.settings.modeindex < 1 then 
                    self.settings.modeindex = #self.settings.modes
                end
            end
            local w = self.settings.modes[self.settings.modeindex].width
            local h = self.settings.modes[self.settings.modeindex].height
            Gui.Label{ text=' '..w.."x"..' '..h, size = {'tight'}}
            if Gui.Button{ text=" + ", size = {'tight'} } then
                self.settings.modeindex = self.settings.modeindex + 1
                if self.settings.modeindex > #self.settings.modes then 
                    self.settings.modeindex = 1
                end
            end
        Gui.group.pop{}
        
        if Gui.Checkbox{ checked=self.settings.mode.fullscreen, text="Fullscreen"} then
            self.settings.mode.fullscreen = not self.settings.mode.fullscreen
        end
        if Gui.Checkbox{ checked=(self.settings.mode.fullscreentype=="desktop"), text="Use Borderless Fullscreen"} then
            if self.settings.mode.fullscreentype == "desktop" then
                self.settings.mode.fullscreentype = "normal"
                self.settings.mode.borderless = false
            else
                self.settings.mode.fullscreentype = "desktop"
                self.settings.mode.borderless = true
            end
        end
        Gui.group.push{ grow="right" }
            Gui.Label{ text="Anti-Aliasing"}
            if Gui.Button{ text=" - ", size={'tight'} } then
                self.settings.fsaa = self.settings.fsaa / 2
                if self.settings.fsaa == 0 then
                    self.settings.fsaa = 16
                end
                if self.settings.fsaa < 1 then
                    self.settings.fsaa = 0
                end
            end
            Gui.Label{ text=' '..self.settings.fsaa..' ', size={'tight'}}
            if Gui.Button{ text=" + ", size={'tight'} } then
                self.settings.fsaa = self.settings.fsaa * 2
                if self.settings.fsaa == 0 then
                    self.settings.fsaa = 1
                end
                if self.settings.fsaa > 16 then
                    self.settings.fsaa = 0
                end
            end
        Gui.group.pop{}
        if Gui.Checkbox{ checked=self.settings.mode.vsync, text="V-Sync"} then
            self.settings.mode.vsync = not self.settings.mode.vsync
        end
        if Gui.Checkbox{ checked=self.settings.mode.highdpi, text="High DPI"} then
            self.settings.mode.highdpi = not self.settings.mode.highdpi
        end
        if Gui.Checkbox{ checked=self.settings.mode.srgb, text="sRGB Gamma Correction"} then
            self.settings.mode.srgb = not self.settings.mode.srgb
        end
        Gui.Label{ text="" }
        Gui.group.push{ grow="right" }
            if Gui.Button{ text="Return" } then
                open = false
            end
            if Gui.Button{ text="Apply" } then
                open = false
                self.settings.width = self.settings.modes[self.settings.modeindex].width
                self.settings.height = self.settings.modes[self.settings.modeindex].height
                love.window.setMode( self.settings.width, self.settings.height, self.settings.mode )
            end
        Gui.group.pop{}
    Gui.group.pop{}
    
    return open
end


function settings:save()
    
end

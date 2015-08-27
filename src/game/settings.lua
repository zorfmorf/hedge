
settings = {}


function settings:read()
    self.settings = {}
    local w, h, f = love.window.getMode()
    self.settings.mode = f
    self.settings.width = w
    self.settings.height = h
    self.settings.modes = love.window.getFullscreenModes()
    table.sort(self.settings.modes, 
        function(a, b) return a.width*a.height < b.width*b.height end)
end


function settings:show()
    local open = true
    Gui.group.push{ grow="down" }
        Gui.Label{ text="Resolution: "..self.settings.width.."x"..self.settings.height}
        if Gui.Checkbox{ checked=self.settings.mode.fullscreen, text="Fullscreen"} then
            self.settings.mode.fullscreen = not self.settings.mode.fullscreen
        end
        if Gui.Checkbox{ checked=(self.settings.mode.fullscreentype=="desktop"), text="Borderless"} then
            if self.settings.mode.fullscreentype == "desktop" then
                self.settings.mode.fullscreentype = "normal"
                self.settings.mode.borderless = false
            else
                self.settings.mode.fullscreentype = "desktop"
                self.settings.mode.borderless = true
            end
        end
        if Gui.Checkbox{ checked=self.settings.mode.vsync, text="V-Sync"} then
            self.settings.mode.vsync = not self.settings.mode.vsync
        end
        if Gui.Checkbox{ checked=self.settings.highdpi, text="High DPI"} then
            self.settings.mode.highdpi = not self.settings.mode.highdpi
        end
        if Gui.Checkbox{ checked=self.settings.mode.srgb, text="sRGB Gamma Correction"} then
            self.settings.mode.srgb = not self.settings.mode.srgb
        end
        if Gui.Button{ text="Return" } then
            open = false
        end
    Gui.group.pop{}
    
    -- now update the options
    love.window.setMode( self.settings.width, self.settings.height, self.settings.mode )
    
    return open
end


function settings:save()
    
end

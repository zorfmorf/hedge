
Gui.core.style = require "view.style"

hud_edit = {}

-- list of all menu dialogs
local menus = { }
menus.brush = false


-- topbar with options, brush, exit buttons
local function topbar()
    Gui.group.push{ grow = "right", pos = { 0, 0 }, size = {screen.w, G_TOPBAR_HEIGHT}, pad = G_TOPBAR_PAD, bkg = true }
        Gui.Button{ text = "Save", size = {100} }
        Gui.Button{ text = "Options", size = {100} }
        if Gui.Button{ text = "Brushes", size = {100} } then menus.brush = not menus.brush end
        Gui.Button{ text = "Quit", size = {100} }
        Gui.Label{ text = "FPS: " .. love.timer.getFPS() }
    Gui.group.pop{}
end


-- menu where you can edit existing brushes
local function brushmenu()
    Gui.group.push{ grow = "down", pos = { screen.w * 0.1, screen.h * 0.25 }, size = {screen.w * 0.5}, pad = 10, bkg = true, border = 1 }
        Gui.Label{ text = "Currently defined brushes:" }
        
        Gui.group.push{ grow = "right", size = {130} }
            Gui.Label{ text = "Name" }
            Gui.Label{ text = "Walkable" }
            Gui.Label{ text = "Floor" }
            Gui.Label{ text = "Objects" }
            Gui.Label{ text = "Overlay" }
        Gui.group.pop{}
        for i,brush in ipairs(game.brushes) do
            Gui.group.push{ grow = "right", size = {130} }
                Gui.Input{ info = {text = brush.name} }
                if Gui.Checkbox{ checked = not brush.blocked } then brush.blocked = not brush.blocked end
                if Gui.Button{ text = "X", size = {'tight'} } then table.remove(game.brushes, i) i = i - 1 end
                
            Gui.group.pop{}
        end
        if Gui.Button{ text = "Add new brush" } then table.insert(game.brushes, Brush(#game.brushes + 1)) end
        
    Gui.group.pop{}
end


-- quick access menu containing last used tools
local function tools()
    -- expandable bottom right tile selector
    --Gui.group.push{ grow = "up", pos = { screen.w - 100, screen.h - 50}, bkg = true }
    --    Gui.Button{ text = "T", size = { "tight" } }
    --    Gui.Button{ text = "P", size = { "tight" } }
    --Gui.group.pop{}
end


function hud_edit:update(dt)
    
    topbar()
    
    if menus.brush then brushmenu() end
    
    tools()
end


-- we need this to not draw tiles while menus are open
function hud_edit:menuIsOpen()
    for i,item in pairs(menus) do
        if item == true then return true end
    end
    return false
end

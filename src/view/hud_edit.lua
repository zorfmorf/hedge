
Gui.core.style = require "view.style"

hud_edit = {}

-- list of all menu dialogs
local menus = { }
menus.brush = false -- brush configurator
menus.tiles = false -- tile for brush selector


-- currently selected tile atlas
local currentatlas = 1

-- if true, marks walkable tiles
local showWalkable = false


function hud_edit:showWalkable()
    return showWalkable
end


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


-- creates a customized draw function for the brush menu
local function brushTile_drawFunction(tile)
    return  function(state, title, x,y,w,h)
                local atlas = game.atlanti[tile[1]]
                local quad = love.graphics.newQuad(tile[2] * C_TILE_SIZE, 
                    tile[3] * C_TILE_SIZE, C_TILE_SIZE, C_TILE_SIZE, 
                    atlas.img:getWidth(), atlas.img:getHeight())
                love.graphics.draw(atlas.img, quad, x, y) 
            end
end


-- menu where you can edit existing brushes
local function brushmenu()
    Gui.group.push{ grow = "down", pos = { screen.w * 0.1, screen.h * 0.25 }, size = {screen.w * 0.5}, pad = 10, bkg = true, border = 1 }
        Gui.Label{ text = "Currently defined brushes:" }
        
        for i,brush in ipairs(game.brushes) do
            Gui.group.push{ grow = "right", size = {130}, spacing = 10 }
                
                -- brush name
                Gui.Input{ info = {text = brush.name}, size = {100} }
                
                -- brush walkable
                if Gui.Checkbox{ checked = not brush.blocking, text = "isWalkable", size = { "tight" } } then brush.blocking = not brush.blocking end
                
                Gui.Label{ text = "  ", size = { "tight" } }
                
                -- brush tiles
                Gui.Label{ text = "Floor:", size = { "tight" } }
                if brush.tiles then
                    for i,tile in ipairs(brush.tiles) do
                        if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                            table.remove(brush.tiles, i)
                            i = i - 1
                        end
                    end
                end
                if Gui.Button{ text = " + ", size = {'tight'} } then menus.tiles = { "tiles", i } end
                
                Gui.Label{ text = "    ", size = { "tight" } }
                
                -- object tiles
                Gui.Label{ text = "Object:", size = { "tight" } }
                if brush.objects then
                    for i,tile in ipairs(brush.objects) do
                        if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                            table.remove(brush.objects, i)
                            i = i - 1
                        end
                    end
                end
                if Gui.Button{ text = " + ", size = {'tight'} } then menus.tiles = { "objects", i } end
                
                Gui.Label{ text = "    ", size = { "tight" } }
                
                -- overlay tiles
                Gui.Label{ text = "Overlay:", size = { "tight" } }
                if brush.overlays then
                    for i,tile in ipairs(brush.overlays) do
                        if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                            table.remove(brush.overlays, i)
                            i = i - 1
                        end
                    end
                end
                if Gui.Button{ text = " + ", size = {'tight'} } then menus.tiles = { "overlays", i} end
                
                Gui.Label{ text = "    ", size = { "tight" } }
                
                -- delete brush
                if Gui.Button{ text = " - ", size = {'tight'} } then table.remove(game.brushes, i) i = i - 1 end
                
            Gui.group.pop{}
        end
        if Gui.Button{ text = "Add new brush" } then table.insert(game.brushes, Brush(#game.brushes + 1)) end
        if Gui.Button{ text = "Okay" } then menus.brush = false end
        
    Gui.group.pop{}
end


local function tileselector()
    local atlas = game.atlanti[currentatlas]
    Gui.Label{ text = "", draw = function() love.graphics.clear() love.graphics.draw(atlas.img) end}
end


-- quick access menu containing last used tools
local function tools()
    Gui.group.push{ grow = "right", pos = { 0, screen.h - C_TILE_SIZE}, size = { screen.w, C_TILE_SIZE }, bkg = true }        
        Gui.Label{ text = "Brushes:", size = {60} }
        for i,brush in ipairs(game.brushes) do
            if Gui.Button{ text = brush.name, size = {C_TILE_SIZE * 2, C_TILE_SIZE} } then
                game.brush = i
            end
        end
        
        Gui.Label{ text = "Toggles:", size = {60} }
        if Gui.Button{ text = "w: " .. tostring(showWalkable), size = {C_TILE_SIZE * 2, C_TILE_SIZE} } then
            showWalkable = not showWalkable
        end
        Gui.Label{ text = "" } -- to fill out the rest of the bar
    Gui.group.pop{}
end


function hud_edit:update(dt)
    
    if menus.tiles then
        tileselector()
    else
        
        if menus.brush then brushmenu() return end
        
        topbar()
        tools()
        
    end
end


-- we need this to not draw tiles while menus are open
function hud_edit:menuIsOpen()
    for i,item in pairs(menus) do
        if item == true then return true end
    end
    if love.mouse.getY() > screen.h - C_TILE_SIZE then 
        return true 
    end
    return false
end


function hud_edit:mousepressed(x, y, button)
    
    -- if in tileselection select the tile based on current atlas and mousepos
    if button == "l" and menus.tiles then
        
        local tx = math.floor(x / C_TILE_SIZE)
        local ty = math.floor(y / C_TILE_SIZE)
        
        if menus.tiles[1] == "tiles" then
            game.brushes[menus.tiles[2]]:addTile(currentatlas, tx, ty)
        end
        if menus.tiles[1] == "objects" then
            game.brushes[menus.tiles[2]]:addObject(currentatlas, tx, ty)
        end
        if menus.tiles[1] == "overlays" then
            game.brushes[menus.tiles[2]]:addOverlay(currentatlas, tx, ty)
        end
        
        menus.tiles = false
    end
    
end


function hud_edit:catchKey(key, isrepeat)
    if menus.tiles and key == "left" then
        currentatlas = currentatlas - 1
        if currentatlas < 1 then currentatlas = #game.atlanti end
        return true
    end
    if menus.tiles and key == "right" then
        currentatlas = currentatlas + 1
        if currentatlas > #game.atlanti then currentatlas = 1 end
        return true
    end
    return false
end

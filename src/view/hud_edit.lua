
Gui.core.style = require "view.style"

hud_edit = {}

-- list of all menu dialogs
local menus = { }
menus.brush = false -- brush configurator
menus.tiles = false -- tile for brush selector


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
    return  function(state, text, align, x,y,w,h)
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
                Gui.Input{ info = {text = brush.name} }
                
                -- brush walkable
                if Gui.Checkbox{ checked = not brush.blocked, text = "isWalkable", size = { "tight" } } then brush.blocked = not brush.blocked end
                
                -- brush tiles
                Gui.Label{ text = "Floor:", size = { "tight" } }
                if brush.tiles then
                    for i,tile in ipairs(brush.tiles) do
                        Gui.Label{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) }
                    end
                end
                if Gui.Button{ text = "+add", size = {'tight'} } then menus.tiles = { "tiles", i } end
                
                -- object tiles
                Gui.Label{ text = "Object:", size = { "tight" } }
                if brush.objects then
                    for i,tile in ipairs(brush.objects) do
                        Gui.Label{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) }
                    end
                end
                if Gui.Button{ text = "+add", size = {'tight'} } then menus.tiles = { "objects", i } end
                
                -- overlay tiles
                Gui.Label{ text = "Overlay:", size = { "tight" } }
                if brush.overlays then
                    for i,tile in ipairs(brush.overlays) do
                        Gui.Label{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) }
                    end
                end
                if Gui.Button{ text = "+add", size = {'tight'} } then menus.tiles = { "overlays", } end
                
                -- delete brush
                if Gui.Button{ text = "-", size = {'tight'} } then table.remove(game.brushes, i) i = i - 1 end
            Gui.group.pop{}
        end
        if Gui.Button{ text = "Add new brush" } then table.insert(game.brushes, Brush(#game.brushes + 1)) end
        
    Gui.group.pop{}
end


local function tileselector()
    local atlas = game.atlanti[1]
    Gui.Label{ text = "", draw = function() love.graphics.clear() love.graphics.draw(atlas.img) end}
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
    
    if menus.tiles then
        tileselector()
    else
    
        topbar()
        
        if menus.brush then brushmenu() end
        
        tools()
    end
end


-- we need this to not draw tiles while menus are open
function hud_edit:menuIsOpen()
    for i,item in pairs(menus) do
        if item == true then return true end
    end
    return false
end


function hud_edit:mousepressed(x, y, button)
    if button == "l" and menus.tiles then
        
        local tx = math.floor(x / C_TILE_SIZE)
        local ty = math.floor(y / C_TILE_SIZE)
        local at = 1
        
        if menus.tiles[1] == "tiles" then
            game.brushes[menus.tiles[2]]:addTile(at, tx, ty)
        end
        if menus.tiles[1] == "objects" then
            game.brushes[menus.tiles[2]]:addObject(at, tx, ty)
        end
        if menus.tiles[1] == "overlays" then
            game.brushes[menus.tiles[2]]:addOverlay(at, tx, ty)
        end
        
        menus.tiles = false
    end
end

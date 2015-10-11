
Gui.core.style = require "view.style"

editorHandler = {}

-- icons
local icon = {
    broom = love.graphics.newImage("img/icon/broom.png"),
    palette = love.graphics.newImage("img/icon/palette.png"),
    block = love.graphics.newImage("img/icon/block.png"),
    boot = love.graphics.newImage("img/icon/walking-boot.png"),
    event = love.graphics.newImage("img/icon/fishing-hook.png"),
    spawn = love.graphics.newImage("img/icon/position-marker.png"),
    npc = love.graphics.newImage("img/icon/npc.png"),
    transition = love.graphics.newImage("img/icon/transition.png"),
    delobj = love.graphics.newImage("img/icon/delobj.png"),
    tile = love.graphics.newImage("img/icon/tile.png"),
    selection = love.graphics.newImage("img/icon/selection.png")
}

-- list of all menu dialogs
local menus = { }
menus.brush = false -- brush selector
menus.brushedit = false -- brush editor
menus.tiles = false -- tile for brush selector
menus.load = false -- map load
menus.npc = false -- npc selector
menus.transition = false -- transition placer
menus.event = false -- event placer
menus.settings = false -- map settings menu

-- layer toggles
local layer = {}
layer.floor1 = true
layer.floor2 = true
layer.object = true
layer.overlay = true
layer.block = false

-- currently selected tile atlas
local currentatlas = 1

-- screen position for the current atlas
local atlaspos = {0, 0}

-- if true, marks walkable tiles
local showWalkable = false

-- if true, marks events on tiles
local showEvents = false

-- name of the currently edited map
local mapname = { text = "" }

-- current map target for map transition placment tool
local transitiontarget = nil

-- current map target for event placement tool
local eventtarget = nil

-- target for placement of singletiletarget
local singletiletarget = nil


local function buttonWidth(text)
    return math.max(love.graphics.getFont():getWidth(text) + 10, 110)
end

function editorHandler:setMapName(text)
    mapname.text = text
end


function editorHandler:getMapName()
    return mapname.text
end


function editorHandler:showWalkable()
    return showWalkable
end


function editorHandler:singleTilePlacement(tx, ty)
    menus.tiles = true
    singletiletarget = { x=tx, y=ty, new=true }
end


function editorHandler:getLayerToggles()
    return layer
end


function editorHandler:showEvents()
    return showEvents
end


function editorHandler:setWalkable(value)
    showWalkable = value
end


function editorHandler:setEvents(value)
    showEvents = value
end


function editorHandler:addEvent(tx, ty)
    game.map:changeEvent(tx, ty, eventtarget)
end


function editorHandler:addNpc(tx, ty)
    local tile = game.map:getTile(tx, ty)
    if tile and tile.npc then
        local npc = entityHandler.get(tile.npc)
        npc.anim = npc.anim + 1
        if npc.anim > 4 then npc.anim = 1 end
    else
        menus.npc = { x=tx, y=ty }
    end
end


function editorHandler:placeTransition(tx, ty)
    if transitiontarget then
        local t = {}
        t[1] = transitiontarget.name
        t[2] = transitiontarget.key
        game.map:changeEvent(tx, ty, t)
    end
end


-- topbar with options, brush, exit buttons
local function topbar()
    Gui.group.push{ grow = "right", pos = { 0, 0 }, size = {screen.w, G_TOPBAR_HEIGHT} }
        if Gui.Button{ text = "New", size = {100} } then st_edit:newMap() end
        Gui.Input{info = mapname, size = {200} }
        if Gui.Button{ text = "Save", size = {100} } then st_edit:saveMap() end
        if Gui.Button{ text = "Load", size = {100} } then menus.load = not menus.load end
        if Gui.Button{ text = "Settings", size = {100} } then menus.settings = not menus.settings end
        if Gui.Button{ text = "Brushes", size = {100} } then menus.brush = not menus.brush end
        if Gui.Button{ text = "Quit", size = {100} } then Gamestate.switch(st_menu_main) end
        Gui.Label{ text = "FPS: " .. love.timer.getFPS() }
    Gui.group.pop{}
end


-- creates a customized draw function for the brush menu
local function brushTile_drawFunction(tile)
    return  function(state, title, x,y,w,h)
                local atlas = brushHandler.getAtlanti()[tile[1]]
                local quad = love.graphics.newQuad(tile[2] * C_TILE_SIZE, 
                    tile[3] * C_TILE_SIZE, C_TILE_SIZE, C_TILE_SIZE, 
                    atlas.img:getWidth(), atlas.img:getHeight())
                if tile.overlay then
                    love.graphics.setColor(150, 150, 255, 255)
                    love.graphics.rectangle("fill", x, y, C_TILE_SIZE, C_TILE_SIZE)
                else
                    love.graphics.setColor(Color.WHITE)
                end
                love.graphics.draw(atlas.img, quad, x, y)
                love.graphics.setColor(Color.WHITE)
            end
end


-- draw function for icon buttons
local function icon_func(img, brush, highlight)
    return  function(state, title, x,y,w,h)
                love.graphics.setColor(Color.WHITE)
                if state == "active" or highlight then
                    love.graphics.setColor(Color.RED)
                end
                if img then love.graphics.draw(img, x, y) end
                if brush then brush:drawPreview(x, y, icon.palette) end
                if state == "hot" or highlight then
                    love.graphics.rectangle("line", x, y, 32, 31)
                end
            end
end


local function brusheditor()
    local brush = brushHandler.getBrush(menus.brushedit)
    Gui.group.push{ grow = "down", pos = { C_TILE_SIZE, C_TILE_SIZE} }
        Gui.Label{ text = "Brush editor menu", size = { "tight" } }
        
        if brush:isObjectBrush() then
            Gui.Label{ text = "First click: Set tile", size = { "tight" } }
            Gui.Label{ text = "Second click: Set to overlay", size = { "tight" } }
            Gui.Label{ text = "Third click: Delete tile", size = { "tight" } }
            local input = {text = brush.name}
            Gui.Input{ info = input, size = {100} }
            brush.name = input.text
            Gui.group.push{ grow = "right" }
                for i=1,brush.ysize do
                    for j=1,brush.xsize do
                        local tile = brush:get(j, i)
                        if tile then
                            if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                                if tile.overlay then
                                    brush.tile[j][i] = nil
                                else
                                    tile.overlay = true
                                end
                            end
                        else
                            if Gui.Button{ text =" ", size = {C_TILE_SIZE} } then
                                 menus.tiles = { "obrush", menus.brushedit, j, i } 
                            end
                        end
                    end
                    if i == 1 then
                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then 
                            brush.xsize = brush.xsize + 1
                        end
                    end
                    Gui.group.pop{}
                    Gui.group.push{ grow = "right" }
                end
                if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then 
                    brush.ysize = brush.ysize + 1
                end
            Gui.group.pop{}
        else
            Gui.group.push{ grow = "right" }
                Gui.group.push{ grow = "down" }
                    
                    local input = {text = brush.name}
                    Gui.Input{ info = input, size = {100} }
                    brush.name = input.text
                    
                     -- brush walkable
                    if Gui.Checkbox{ checked = not brush.blocking, text = "isWalkable", size = { "tight" } } then brush.blocking = not brush.blocking end
                    
                    
                    -- brush tiles
                    Gui.group.push{ grow = "right" }
                        Gui.Label{ text = "Floor:", size = {100} }
                        if brush.tiles then
                            for i,tile in ipairs(brush.tiles) do
                                if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                                    table.remove(brush.tiles, i)
                                    i = i - 1
                                end
                                if i%5 == 0 then
                                    Gui.group.pop{}
                                    Gui.group.push{ grow = "right" }
                                    Gui.Label{ text = "", size = {100} }
                                end
                            end
                        end
                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then menus.tiles = { "tiles", menus.brushedit } end
                    Gui.group.pop{}
                    
                    -- brush2 tiles
                    Gui.group.push{ grow = "right" }
                        Gui.Label{ text = "Floor2:", size = {100} }
                        if brush.tiles2 then
                            for i,tile in ipairs(brush.tiles2) do
                                if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                                    table.remove(brush.tiles2, i)
                                    i = i - 1
                                end
                                if i%5 == 0 then
                                    Gui.group.pop{}
                                    Gui.group.push{ grow = "right" }
                                    Gui.Label{ text = "", size = {100} }
                                end
                            end
                        end
                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then menus.tiles = { "tiles2", menus.brushedit } end
                    Gui.group.pop{}
                        
                        
                    -- object tiles
                    Gui.group.push{ grow = "right" }
                        Gui.Label{ text = "Object:", size = {100} }
                        if brush.objects then
                            for i,tile in ipairs(brush.objects) do
                                if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                                    table.remove(brush.objects, i)
                                    i = i - 1
                                end
                                if i%5 == 0 then
                                    Gui.group.pop{}
                                    Gui.group.push{ grow = "right" }
                                    Gui.Label{ text = "", size = {100} }
                                end
                            end
                        end
                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then menus.tiles = { "objects", menus.brushedit } end
                    Gui.group.pop{}
                        
                    -- overlay tiles
                    Gui.group.push{ grow = "right" }
                        Gui.Label{ text = "Overlay:", size = {100} }
                        if brush.overlays then
                            for i,tile in ipairs(brush.overlays) do
                                if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                                    table.remove(brush.overlays, i)
                                    i = i - 1
                                end
                                if i%5 == 0 then
                                    Gui.group.pop{}
                                    Gui.group.push{ grow = "right" }
                                    Gui.Label{ text = "", size = {100} }
                                end
                            end
                        end
                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then menus.tiles = { "overlays", menus.brushedit } end
                    Gui.group.pop{}
                    
                Gui.group.pop{}
                
                --spacer
                Gui.Label{ text="", size = {50}}
                
                -- intelligent border tools
                Gui.group.push{ grow = "down" }
                    if Gui.Checkbox{ checked = brush.border, text = "Intelligent Border" } then 
                        if brush.border then
                            brush.border = nil
                        else
                            brush:addBorder()
                        end
                    end
                    if brush.border then
                        Gui.Label{ text = "Intelligent borders are applied on the tile2 layer surrounding tiles drawn with this brush" }
                        Gui.group.push{ grow = "right"}
                            
                            -- inner border
                            Gui.group.push{ grow = "down" }
                                Gui.Label{ text="Inner" }
                                Gui.group.push{ grow = "right" }
                                
                                    -- upper left
                                    if brush.border.inner.ul then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.inner.ul) } then
                                            brush.border.inner.ul = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.inner.ul", menus.brushedit }
                                        end
                                    end
                                    
                                    -- upper right
                                    if brush.border.inner.ur then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.inner.ur) } then
                                            brush.border.inner.ur = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.inner.ur", menus.brushedit }
                                        end
                                    end
                                    
                                Gui.group.pop{}
                                Gui.group.push{ grow = "right" }
                                    
                                    -- lower left
                                    if brush.border.inner.ll then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.inner.ll) } then
                                            brush.border.inner.ll = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.inner.ll", menus.brushedit }
                                        end
                                    end
                                    
                                    -- lower right
                                    if brush.border.inner.lr then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.inner.lr) } then
                                            brush.border.inner.lr = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.inner.lr", menus.brushedit }
                                        end
                                    end
                                    
                                Gui.group.pop{}
                            Gui.group.pop{}
                            
                            -- outer border
                            Gui.group.push{ grow = "down" }
                                Gui.Label{ text="Outer" }
                                Gui.group.push{ grow = "right" }
                                
                                    -- upper left
                                    if brush.border.outer.ul then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.outer.ul) } then
                                            brush.border.outer.ul = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.outer.ul", menus.brushedit }
                                        end
                                    end
                                    
                                    -- upper right
                                    if brush.border.outer.ur then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.outer.ur) } then
                                            brush.border.outer.ur = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.outer.ur", menus.brushedit }
                                        end
                                    end
                                    
                                Gui.group.pop{}
                                Gui.group.push{ grow = "right" }
                                    
                                    -- lower left
                                    if brush.border.outer.ll then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.outer.ll) } then
                                            brush.border.outer.ll = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.outer.ll", menus.brushedit }
                                        end
                                    end
                                    
                                    -- lower right
                                    if brush.border.outer.lr then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.outer.lr) } then
                                            brush.border.outer.lr = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.outer.lr", menus.brushedit }
                                        end
                                    end
                                    
                                Gui.group.pop{}
                            Gui.group.pop{}
                            
                            -- side border
                            Gui.group.push{ grow = "down" }
                                Gui.Label{ text="Side" }
                                Gui.group.push{ grow = "right" }
                                
                                    -- upper
                                    Gui.Label{ text="", size={C_TILE_SIZE}}
                                    if brush.border.side.u then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.side.u) } then
                                            brush.border.side.u = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.side.u", menus.brushedit }
                                        end
                                    end
                                    
                                Gui.group.pop{}
                                Gui.group.push{ grow = "right" }
                                    
                                    -- left/right
                                    if brush.border.side.l then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.side.l) } then
                                            brush.border.side.l = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.side.l", menus.brushedit }
                                        end
                                    end
                                    Gui.Label{ text="", size={C_TILE_SIZE}}
                                    if brush.border.side.r then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.side.r) } then
                                            brush.border.side.r= nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.side.r", menus.brushedit }
                                        end
                                    end
                                    
                                Gui.group.pop{}
                                Gui.group.push{ grow = "right" }
                                    
                                    -- lower
                                    Gui.Label{ text="", size={C_TILE_SIZE}}
                                    if brush.border.side.d then
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(brush.border.side.d) } then
                                            brush.border.side.d = nil
                                        end
                                    else
                                        if Gui.Button{ text = "+", size = {C_TILE_SIZE} } then
                                            menus.tiles = { "border.side.d", menus.brushedit }
                                        end
                                    end
                                    
                                Gui.group.pop{}
                            Gui.group.pop{}
                            
                        Gui.group.pop{}
                    end
                Gui.group.pop{}
            Gui.group.pop{}
        end
        
        
        if Gui.Button{ text = "Okay" } then menus.brushedit = false end
        Gui.Label{ text = " " }
        
        -- delete brush
        if Gui.Button{ text = "Delete" } then 
            brushHandler.delete(menus.brushedit)
            menus.brushedit = false
        end
        
    Gui.group.pop{}
end


-- menu where you can edit existing brushes
local function brushmenu()
    Gui.Label{ text = "Currently defined brushes:" }
    Gui.group.push{ grow = "right", pos = {C_TILE_SIZE, C_TILE_SIZE}}
        Gui.group.push{ grow = "down"}
            for i,brush in pairs(brushHandler.getBrushes()) do
                Gui.group.push{ grow = "right" }
                    Gui.Label{ text = brush.name, size = {100} }
                    if Gui.Button{ text = brush.name, size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(nil, brush, brushHandler.currentBrushId() == brush.id) } then
                        brushHandler.selectBrush(brush.id)
                        menus.brush = false
                    end
                    if Gui.Button{ text = "Edit" } then
                        menus.brushedit = brush.id
                    end
                Gui.group.pop{}
                if i % 12 == 0 then
                    Gui.group.pop{}
                    Gui.group.push{ grow = "down", pos = { 2, 2 } }
                end
            end
            if Gui.Button{ text = "Add" } then
                local brush = Brush(0)
                brushHandler.setBrush(brush)
                menus.brushedit = brush.id
            end
            if Gui.Button{ text = "Add ObjBrush" } then
                local brush = OBrush(0)
                brushHandler.setBrush(brush)
                menus.brushedit = brush.id
            end
            if Gui.Button{ text = "Close" } then menus.brush = false end
        Gui.group.pop{}
    Gui.group.pop{}
end


local function settingsmenu()
    Gui.group.push{ grow = "down", pos = {C_TILE_SIZE, C_TILE_SIZE}}
    Gui.Label{ text = "Map-wide settings" }
    if Gui.Checkbox{ checked = game.map:getSetting("simulate_day"), text = "Simulate day/night cycle" } then 
        if game.map:getSetting("simulate_day") then
            game.map:setSetting("simulate_day", nil)
        else
            game.map:setSetting("simulate_day", true)
        end
    end
    Gui.group.pop{}
end


local function tileselector()
    local atlas = brushHandler.getAtlanti()[currentatlas]
    Gui.Label{ text = "", draw = function() love.graphics.clear() love.graphics.draw(atlas.img, atlaspos[1], atlaspos[2]) end}
    Gui.Label{ text = "Mousewheel: Switch atlas\nArrow keys: Move atlas", pos = {screen.w - 200, 0} }
end


local function npcselector()
    Gui.group.push{ grow = "down", spacing = 10 }
    Gui.group.push{ grow = "right", spacing = 10 }
    local counter = 1
    for i,entity in pairs(entityHandler.getAll()) do
        if not (i == 1) then
            if Gui.Button{ text = entity.name, size = { buttonWidth(entity.name) } } then
                entity:place(menus.npc.x, menus.npc.y)
                menus.npc = false
            end
            if counter % 3 == 0 then
                Gui.group.pop{}
                Gui.group.push{ grow = "right", spacing = 10 }
            end
            counter = counter + 1
        end
    end
    Gui.group.pop{}
    Gui.group.pop{}
end


local function eventselector()
    Gui.group.push{ grow = "down", spacing = 10 }
    Gui.group.push{ grow = "right", spacing = 10 }
    for i,event in pairs(eventHandler:getEvents()) do
        if Gui.Button{ text = event.name, size = { buttonWidth(event.name) } } then
            eventtarget = i
            menus.event = false
        end
        if i % 5 == 0 then
            Gui.group.pop{}
            Gui.group.push{ grow = "right", spacing = 10 }
        end
    end
    Gui.group.pop{}
    Gui.group.pop{}
end


local function transitionselector()
    Gui.group.push{ grow = "down", spacing = 10 }
    Gui.group.push{ grow = "right", spacing = 10 }
    for name,map in pairs(st_edit.maps) do
        for key,value in pairs(map.spawns) do
            if Gui.Button{ text = (name..": "..key), size = { buttonWidth(name..": "..key) } } then
                transitiontarget = { name=name, key=key}
                menus.transition = false
            end
        end
        Gui.group.pop{}
        Gui.group.push{ grow = "right", spacing = 10 }
    end
    Gui.group.pop{}
    Gui.group.pop{}
end


local function mapselector()
    Gui.group.push{ grow = "down", spacing = 10 }
    Gui.group.push{ grow = "right", spacing = 10 }
    local i = 1
    for name,map in pairs(st_edit.maps) do
        if Gui.Button{ text = name, size = { buttonWidth(name) } } then
            menus.load = false
            st_edit:loadMap(name)
        end
        if i % 5 == 0 then
            Gui.group.pop{}
            Gui.group.push{ grow = "right", spacing = 10 }
        end
        i = i + 1
    end
    Gui.group.pop{}
    Gui.group.pop{}
end


local function drawTooltip(title)
    local mx,my = love.mouse.getPosition()
    Gui.Label{text = title, pos = {mx+10,my-40}}
end


-- sidebar to select/deselect individual display of layers
local function layerbar()
    Gui.group.push{ grow = "down", pos = { screen.w - 85, C_TILE_SIZE * 2} }
        
        Gui.Label{ text = "Active Layers" }
        
        if Gui.Checkbox{ checked = layer.floor1, text = "Floor1" } then 
            layer.floor1 = not layer.floor1
        end
        
        if Gui.Checkbox{ checked = layer.floor2, text = "Floor2" } then 
            layer.floor2 = not layer.floor2
        end
        
        if Gui.Checkbox{ checked = layer.object, text = "Object" } then 
            layer.object = not layer.object
        end
        
        if Gui.Checkbox{ checked = layer.overlay, text = "Overlay" } then 
            layer.overlay = not layer.overlay
        end
        
        if Gui.Checkbox{ checked = layer.block, text = "Blocks" } then 
            layer.block = not layer.block
        end
    
    Gui.group.pop{}
end


-- quick access menu containing last used tools
local function tools()
    Gui.group.push{ grow = "right", pos = { 0, screen.h - C_TILE_SIZE}, size = { screen.w, C_TILE_SIZE } }
        
        Gui.Label{ text = "Tools:", size = {60} }
        if Gui.Button{ id = "tool_place", text = "Place tiles without a brush", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.tile, nil, brushHandler.currentBrushId() == -8) } then
            brushHandler.selectBrush(-8)
        end
        if Gui.Button{ id = "tool_delete", text = "Delete tile", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.broom, nil, brushHandler.currentBrushId() == -1) } then
            brushHandler.selectBrush(-1)
        end
        if Gui.Button{ id = "tool_delete_obj", text = "Delete object/overlay/npc/event", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.delobj, nil, brushHandler.currentBrushId() == -7) } then
            brushHandler.selectBrush(-7)
        end
        if Gui.Button{ id = "tool_walkable", text = "Switch walkable", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.boot, nil, brushHandler.currentBrushId() == -2) } then
            brushHandler.selectBrush(-2)
        end
        if Gui.Button{ id = "tool_event", text = "Add/Remove Event", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.event, nil, brushHandler.currentBrushId() == -3) } then
            brushHandler.selectBrush(-3)
            menus.event = true
        end
        if Gui.Button{ id = "tool_spawn", text = "Add/Remove Spawn", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.spawn, nil, brushHandler.currentBrushId() == -4)} then
            brushHandler.selectBrush(-4)
        end
        if Gui.Button{ id = "tool_transition", text = "Add/Remove transition", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.transition, nil, brushHandler.currentBrushId() == -6)} then
            brushHandler.selectBrush(-6)
            menus.transition = true
        end
        if Gui.Button{ id = "tool_npc", text = "Add/Remove Npc", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.npc, nil, brushHandler.currentBrushId() == -5)} then
            brushHandler.selectBrush(-5)
        end
        if Gui.Button{ id = "tool_selection", text = "Create brush from selection", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.selection, nil, brushHandler.currentBrushId() == -9)} then
            brushHandler.selectBrush(-9)
        end
        
        Gui.Label{ text = "Brushes:", size = {60} }
        if Gui.Button{ id = "tool_brush_add", text = "+", size = {C_TILE_SIZE, C_TILE_SIZE} } then
            menus.brush = true
        end
        for k,i in ipairs(brushHandler.getRecentBrushes()) do
            local brush = brushHandler.getBrush(i)
            if brush then
                if Gui.Button{ id = "tool_brush_"..i, text = brush.name, size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(nil, brush, brushHandler.currentBrushId() == i) } then
                    brushHandler.selectBrush(i)
                end
            end
        end
        
        Gui.Label{ text = "Toggles:", size = {60} }
        if Gui.Button{ id = "toggle_walkable", text = "w: " .. tostring(showWalkable), size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.block, nil, showWalkable == true)} then
            showWalkable = not showWalkable
        end
        if Gui.Button{ id = "toggle_event", text = "e: " .. tostring(showWalkable), size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.event, nil, showEvents == true)} then
            showEvents = not showEvents
        end
        
        Gui.Label{ text = "" } -- to fill out the rest of the bar
    Gui.group.pop{}
    
    
    -- tool tooltips
    -- tooltip (see above)
    if Gui.mouse.isHot("tool_place") then drawTooltip("Add a tile without a brush on uppermost active layer") end
    if Gui.mouse.isHot("tool_brush_add") then drawTooltip("Add a brush") end
    if Gui.mouse.isHot("tool_delete") then drawTooltip("Deletion tool") end
    if Gui.mouse.isHot("tool_walkable") then drawTooltip("Walkable tool") end
    if Gui.mouse.isHot("tool_event") then drawTooltip("Event tool") end
    if Gui.mouse.isHot("tool_spawn") then drawTooltip("Spawn placement tool") end
    if Gui.mouse.isHot("tool_transition") then drawTooltip("Transition tool") end
    if Gui.mouse.isHot("tool_npc") then drawTooltip("Npc placement tool") end
    if Gui.mouse.isHot("toggle_walkable") then drawTooltip("Toggle display of walkable tiles") end
    if Gui.mouse.isHot("toggle_event") then drawTooltip("Toggle display of events") end
    if Gui.mouse.isHot("tool_delete_obj") then drawTooltip("Delete object & overlay & event of tile") end
    if Gui.mouse.isHot("tool_selection") then drawTooltip("Create a new brush by selecting an area on the map") end
    for i,brush in ipairs(brushHandler.getBrushes()) do
        if Gui.mouse.isHot("tool_brush_"..i) then drawTooltip(brush.name) end
    end
end


function editorHandler:drawEventTooltip()
    local mx, my = camera:mousepos()
    local tx = math.floor(mx / C_TILE_SIZE)
    local ty = math.floor(my / C_TILE_SIZE)
    local tile = game.map:getTile(tx, ty)
    if tile and tile.event then
        local text = "Event " .. tostring(tile.event) .. " not found"
        if type(tile.event) == "table" then
            text = "Transition to "..tile.event[1]..":"..tostring(tile.event[2])
        else
            local elist = eventHandler:getEvents()
            if elist[tile.event] then
                text = elist[tile.event].name
            end
        end
        love.graphics.setColor(Color.BLACK)
        love.graphics.rectangle("fill", mx + C_TILE_SIZE, my - C_TILE_SIZE, love.graphics.getFont():getWidth(text) + C_TILE_SIZE, C_TILE_SIZE)
        love.graphics.setColor(Color.WHITE)
        love.graphics.print(text, mx + C_TILE_SIZE * 1.5, my - C_TILE_SIZE * 0.75)
    end
end


function editorHandler:drawNpcTooltip()
    local mx, my = camera:mousepos()
    local tx = math.floor(mx / C_TILE_SIZE)
    local ty = math.floor(my / C_TILE_SIZE)
    local tile = game.map:getTile(tx, ty)
    if tile and tile.npc then
        local npc = entityHandler.get(tile.npc)
        if npc then
            love.graphics.setColor(Color.BLACK)
            love.graphics.rectangle("fill", mx + C_TILE_SIZE, my - C_TILE_SIZE, love.graphics.getFont():getWidth(npc.name) + C_TILE_SIZE, C_TILE_SIZE)
            love.graphics.setColor(Color.WHITE)
            love.graphics.print(npc.name, mx + C_TILE_SIZE * 1.5, my - C_TILE_SIZE * 0.75)
        end
    end
end


function editorHandler:update(dt)
    
    if menus.tiles then tileselector() end
    if menus.load then mapselector() end
    if menus.npc then npcselector() end
    if menus.transition then transitionselector() end
    if menus.event then eventselector() end
    if menus.brushedit and not menus.tiles then brusheditor() end
        
    if not (menus.tiles or menus.load or menus.npc or menus.transition or menus.event or menus.brushedit) then
        
        if menus.brush then brushmenu() return end
        if menus.settings then settingsmenu() end
        
        topbar()
        layerbar()
        tools()
        
    end
end


-- whether a menu dialog is currently open
function editorHandler:menuOpen()
    for i,item in pairs(menus) do
        if item then return true end
    end
    return false
end


-- don't place tiles when interacting with menus
function editorHandler:mouseIsOnMenu()
    if editorHandler:menuOpen() then
        return true
    end
    if love.mouse.getY() > screen.h - C_TILE_SIZE then 
        return true 
    end
    return false
end


function editorHandler:mousepressed(x, y, button)
    
    -- if in tileselection mode
    if menus.tiles then
        
        
        -- select tile based on current atlas
        if button == "l" then
            
            local tx = math.floor((x - atlaspos[1]) / C_TILE_SIZE)
            local ty = math.floor((y - atlaspos[2]) / C_TILE_SIZE)
            
            if singletiletarget then
                
                -- don't do anything on first click, otherwise
                -- we immediately select a tile and close the menu again
                -- before the user was able to do anything
                if singletiletarget.new then
                    singletiletarget.new = false
                else
                        
                    local value = {currentatlas, tx, ty}
                    
                    local x = singletiletarget.x
                    local y = singletiletarget.y
                    
                    local tile = game.map:getTile(x, y)
                    
                    -- now place tile on lowest possible unset tile, ignoring
                    -- inactive layers
                    if tile then
                        if layer.floor1 and not tile.floor then
                            tile.floor = value
                        elseif layer.floor2 and not tile.floor2 then
                            tile.floor2 = value
                        elseif layer.object and not tile.object then
                            tile.object = value
                        elseif layer.overlay and not tile.overlay then
                            tile.overlay = value
                        end
                    else
                        if layer.floor1 then
                            game.map:setTile(x, y, value, nil, nil, nil, true)
                        elseif layer.floor2 then
                            game.map:setTile(x, y, nil, value, nil, nil, true)
                        elseif layer.object then
                            game.map:setTile(x, y, nil, nil, value, nil, true)
                        elseif layer.overlay then
                            game.map:setTile(x, y, nil, nil, nil, value, true)
                        end
                    end
                    singletiletarget = nil
                    menus.tiles = false
                end
            else
                local brush = brushHandler.getBrush(menus.tiles[2])
                if menus.tiles[1] == "tiles" then
                    brush:addTile(currentatlas, tx, ty)
                end
                if menus.tiles[1] == "tiles2" then
                    brush:addTile2(currentatlas, tx, ty)
                end
                if menus.tiles[1] == "objects" then
                    brush:addObject(currentatlas, tx, ty)
                end
                if menus.tiles[1] == "overlays" then
                    brush:addOverlay(currentatlas, tx, ty)
                end
                if menus.tiles[1] == "border.inner.ul" then
                    brush.border.inner.ul = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.inner.ur" then
                    brush.border.inner.ur = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.inner.ll" then
                    brush.border.inner.ll = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.inner.lr" then
                    brush.border.inner.lr = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.outer.ul" then
                    brush.border.outer.ul = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.outer.ur" then
                    brush.border.outer.ur = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.outer.ll" then
                    brush.border.outer.ll = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.outer.lr" then
                    brush.border.outer.lr = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.side.u" then
                    brush.border.side.u = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.side.l" then
                    brush.border.side.l = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.side.r" then
                    brush.border.side.r = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "border.side.d" then
                    brush.border.side.d = {currentatlas, tx, ty}
                end
                if menus.tiles[1] == "obrush" then
                    brush:set(menus.tiles[3], menus.tiles[4], {currentatlas, tx, ty})
                end
                
                menus.tiles = false
            end
            
        end
                
        -- switch current atlas on mousewheel
        if button == "wu" then
            currentatlas = currentatlas - 1
            atlaspos = {0, 0}
            if currentatlas < 1 then currentatlas = #brushHandler.getAtlanti() end
        end
        
        if button == "wd" then
            currentatlas = currentatlas + 1
            atlaspos = {0, 0}
            if currentatlas > #brushHandler.getAtlanti() then currentatlas = 1 end
        end
    end
    
    if not editorHandler:menuOpen() then
        if button == "r" then
            local mx, my = camera:mousepos()
            local tx = math.floor(mx / C_TILE_SIZE)
            local ty = math.floor(my / C_TILE_SIZE)
            -- delete npc on rightclick
            if brushHandler.currentBrushId() == -5 then
                game.map:removeEntity(tx, ty)
            end
            if brushHandler.currentBrushId() == -3 then
                game.map:changeEvent(tx, ty, nil)
            end
        end
    end
end


-- Give the hud the ability to intercept key presses
function editorHandler:catchKey(key, isrepeat)
    
    -- switch tile atlanti on key press
    if menus.tiles and key == "left" then
        atlaspos[1] = atlaspos[1] + C_TILE_SIZE * 8
        return true
    end
    if menus.tiles and key == "right" then
        atlaspos[1] = atlaspos[1] - C_TILE_SIZE * 8
        return true
    end
    if menus.tiles and key == "up" then
        atlaspos[2] = atlaspos[2] + C_TILE_SIZE * 8
        return true
    end
    if menus.tiles and key == "down" then
        atlaspos[2] = atlaspos[2] - C_TILE_SIZE * 8
        return true
    end
    
    if self:menuOpen() and key == "escape" then
        for key,value in pairs(menus) do
            menus[key] = false
        end
        return true
    end
    
    -- key hasn't been intercepted
    return false
end

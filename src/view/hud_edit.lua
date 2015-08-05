
Gui.core.style = require "view.style"

hud_edit = {}

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
    delobj = love.graphics.newImage("img/icon/delobj.png")
}

-- list of all menu dialogs
local menus = { }
menus.brush = false -- brush configurator
menus.tiles = false -- tile for brush selector
menus.load = false -- map load
menus.npc = false -- npc selector
menus.transition = false -- transition placer
menus.event = false -- event placer


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


local function buttonWidth(text)
    return math.max(love.graphics.getFont():getWidth(text) + 10, 110)
end

function hud_edit:setMapName(text)
    mapname.text = text
end


function hud_edit:getMapName()
    return mapname.text
end


function hud_edit:showWalkable()
    return showWalkable
end


function hud_edit:showEvents()
    return showEvents
end


function hud_edit:setWalkable(value)
    showWalkable = value
end


function hud_edit:setEvents(value)
    showEvents = value
end


function hud_edit:addEvent(tx, ty)
    game.map:changeEvent(tx, ty, eventtarget)
end


function hud_edit:addNpc(tx, ty)
    local tile = game.map:getTile(tx, ty)
    if tile and tile.npc then
        local npc = entityHandler.get(tile.npc)
        npc.anim = npc.anim + 1
        if npc.anim > 4 then npc.anim = 1 end
    else
        menus.npc = { x=tx, y=ty }
    end
end


function hud_edit:placeTransition(tx, ty)
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
        Gui.Button{ text = "Options", size = {100} }
        if Gui.Button{ text = "Brushes", size = {100} } then menus.brush = not menus.brush end
        if Gui.Button{ text = "Quit", size = {100} } then Gamestate.switch(st_menu_main) end
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
    Gui.group.push{ grow = "down", pos = { C_TILE_SIZE, C_TILE_SIZE } }
        Gui.Label{ text = "Currently defined brushes:" }
        
        for i,brush in ipairs(game.brushes) do
            Gui.group.push{ grow = "right", size = {130}, spacing = 10 }
                
                -- brush name
                local input = {text = brush.name}
                Gui.Input{ info = input, size = {100} }
                brush.name = input.text
                
                -- brush walkable
                if Gui.Checkbox{ checked = not brush.blocking, text = "isWalkable", size = { "tight" } } then brush.blocking = not brush.blocking end
                
                Gui.Label{ text = "  ", size = { "tight" } }
                
                
                Gui.group.push{ grow = "down" }
                
                
                    -- brush tiles
                    Gui.group.push{ grow = "right" }
                        Gui.Label{ text = "Floor:" }
                        if brush.tiles then
                            for i,tile in ipairs(brush.tiles) do
                                if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                                    table.remove(brush.tiles, i)
                                    i = i - 1
                                end
                            end
                        end
                        if Gui.Button{ text = " + ", size = {'tight'} } then menus.tiles = { "tiles", i } end
                    Gui.group.pop{}
                    
                    
                    -- object tiles
                    Gui.group.push{ grow = "right" }
                        Gui.Label{ text = "Object:" }
                        if brush.objects then
                            for i,tile in ipairs(brush.objects) do
                                if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                                    table.remove(brush.objects, i)
                                    i = i - 1
                                end
                            end
                        end
                        if Gui.Button{ text = " + ", size = {'tight'} } then menus.tiles = { "objects", i } end
                    Gui.group.pop{}
                    
                    
                    -- overlay tiles
                    Gui.group.push{ grow = "right" }
                        Gui.Label{ text = "Overlay:" }
                        if brush.overlays then
                            for i,tile in ipairs(brush.overlays) do
                                if Gui.Button{ text = "", size = {C_TILE_SIZE}, draw = brushTile_drawFunction(tile) } then
                                    table.remove(brush.overlays, i)
                                    i = i - 1
                                end
                            end
                        end
                        if Gui.Button{ text = " + ", size = {'tight'} } then menus.tiles = { "overlays", i} end
                    Gui.group.pop{}
                    
                Gui.group.pop{}
                
                Gui.Label{ text = "    ", size = { "tight" } }
                
                local event = { text = "" }
                if brush.event then event.text = tostring(brush.event) end
                Gui.Input{ info = event, size = {100} }
                brush.event = tonumber(event.text)
                
                Gui.Label{ text = "    ", size = { "tight" } }
                
                -- delete brush
                if Gui.Button{ text = "Delete" } then table.remove(game.brushes, i) i = i - 1 end
                
            Gui.group.pop{}
        end
        if Gui.Button{ text = "Add new brush" } then table.insert(game.brushes, Brush(#game.brushes + 1)) end
        if Gui.Button{ text = "Okay" } then menus.brush = false end
        
    Gui.group.pop{}
end


local function tileselector()
    local atlas = game.atlanti[currentatlas]
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


local function drawTooltip(title)
    local mx,my = love.mouse.getPosition()
    Gui.Label{text = title, pos = {mx+10,my-40}}
end


-- quick access menu containing last used tools
local function tools()
    Gui.group.push{ grow = "right", pos = { 0, screen.h - C_TILE_SIZE}, size = { screen.w, C_TILE_SIZE } }
        
        Gui.Label{ text = "Tools:", size = {60} }
        if Gui.Button{ id = "tool_delete", text = "Delete tile", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.broom, nil, game.brush == -1) } then
            game.brush = -1
        end
        if Gui.Button{ id = "tool_delete_obj", text = "Delete object/overlay", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.delobj, nil, game.brush == -7) } then
            game.brush = -7
        end
        if Gui.Button{ id = "tool_walkable", text = "Switch walkable", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.boot, nil, game.brush == -2) } then
            game.brush = -2
        end
        if Gui.Button{ id = "tool_event", text = "Add/Remove Event", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.event, nil, game.brush == -3) } then
            game.brush = -3
            menus.event = true
        end
        if Gui.Button{ id = "tool_spawn", text = "Add/Remove Spawn", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.spawn, nil, game.brush == -4)} then
            game.brush = -4
        end
        if Gui.Button{ id = "tool_transition", text = "Add/Remove transition", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.transition, nil, game.brush == -6)} then
            game.brush = -6
            menus.transition = true
        end
        if Gui.Button{ id = "tool_npc", text = "Add/Remove Npc", size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(icon.npc, nil, game.brush == -5)} then
            game.brush = -5
        end
        
        Gui.Label{ text = "Brushes:", size = {60} }
        for i,brush in ipairs(game.brushes) do
            if Gui.Button{ id = "tool_brush_"..i, text = brush.name, size = {C_TILE_SIZE, C_TILE_SIZE}, draw = icon_func(nil, brush, game.brush == i) } then
                game.brush = i
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
    if Gui.mouse.isHot("tool_delete") then drawTooltip("Deletion tool") end
    if Gui.mouse.isHot("tool_walkable") then drawTooltip("Walkable tool") end
    if Gui.mouse.isHot("tool_event") then drawTooltip("Event tool") end
    if Gui.mouse.isHot("tool_spawn") then drawTooltip("Spawn placement tool") end
    if Gui.mouse.isHot("tool_transition") then drawTooltip("Transition tool") end
    if Gui.mouse.isHot("tool_npc") then drawTooltip("Npc placement tool") end
    if Gui.mouse.isHot("toggle_walkable") then drawTooltip("Toggle display of walkable tiles") end
    if Gui.mouse.isHot("toggle_event") then drawTooltip("Toggle display of events") end
    if Gui.mouse.isHot("tool_delete_obj") then drawTooltip("Delete object & overlay & event of tile") end
    for i,brush in ipairs(game.brushes) do
        if Gui.mouse.isHot("tool_brush_"..i) then drawTooltip(brush.name) end
    end
end


function hud_edit:drawEventTooltip()
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


function hud_edit:drawNpcTooltip()
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


function hud_edit:update(dt)
    
    if menus.tiles then tileselector() end
    if menus.load then mapselector() end
    if menus.npc then npcselector() end
    if menus.transition then transitionselector() end
    if menus.event then eventselector() end
        
    if not (menus.tiles or menus.load or menus.npc or menus.transition or menus.event) then
        
        if menus.brush then brushmenu() return end
        
        topbar()
        tools()
        
    end
end


-- whether a menu dialog is currently open
function hud_edit:menuOpen()
    for i,item in pairs(menus) do
        if item then return true end
    end
    return false
end


-- don't place tiles when interacting with menus
function hud_edit:mouseIsOnMenu()
    if hud_edit:menuOpen() then
        return true
    end
    if love.mouse.getY() > screen.h - C_TILE_SIZE then 
        return true 
    end
    return false
end


function hud_edit:mousepressed(x, y, button)
    
    -- if in tileselection mode
    if menus.tiles then
        
        -- select tile based on current atlas
        if button == "l" then
            
            local tx = math.floor((x - atlaspos[1]) / C_TILE_SIZE)
            local ty = math.floor((y - atlaspos[2]) / C_TILE_SIZE)
            
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
                
        -- switch current atlas on mousewheel
        if button == "wu" then
            currentatlas = currentatlas - 1
            atlaspos = {0, 0}
            if currentatlas < 1 then currentatlas = #game.atlanti end
        end
        
        if button == "wd" then
            currentatlas = currentatlas + 1
            atlaspos = {0, 0}
            if currentatlas > #game.atlanti then currentatlas = 1 end
        end
    end
    
    
    if not hud_edit:menuOpen() then
        if button == "r" then
            local mx, my = camera:mousepos()
            local tx = math.floor(mx / C_TILE_SIZE)
            local ty = math.floor(my / C_TILE_SIZE)
            -- delete npc on rightclick
            if game.brush == -5 then
                game.map:removeEntity(tx, ty)
            end
            if game.brush == -3 then
                game.map:changeEvent(tx, ty, nil)
            end
        end
    end
end


-- Give the hud the ability to intercept key presses
function hud_edit:catchKey(key, isrepeat)
    
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

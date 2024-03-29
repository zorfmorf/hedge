
st_edit = {}

camera = nil


-- helper var to not unnecessarily update the same tile
-- multiple times while dragging a tool across the map
local lastTile = {-1000, -1000}

local function isNewTile(x, y)
    local result = not (lastTile[1] == x and lastTile[2] == y)
    if result then lastTile = { x, y } end
    return result
end


function st_edit:reloadMapIndex()
    self.maps = {}
    local files = love.filesystem.getDirectoryItems( C_MAP_MASTER )
    for i,item in ipairs(files) do
        if love.filesystem.isFile(C_MAP_MASTER..item) and item:find(C_MAP_SUFFIX) then
            local map = maploader:read(C_MAP_MASTER, item)
            self.maps[map.name] = map
        end
    end
end


function st_edit:reloadMap(name)
    local map = maploader:read(C_MAP_MASTER, name..C_MAP_SUFFIX)
    self.maps[map.name] = map
end


function st_edit:enter()
    
    entityHandler.load()
    self:reloadMapIndex()
    
    animationHelper.init()
    eventHandler:init()
    game:init(true)
    brushHandler.init()
    self:loadSettings()
    
    camera = Camera(0, 0)
    
end


function st_edit:update(dt)
    
    for id,entity in pairs(game.map.entities) do
        entity:update(0)
    end
    
    editorHandler:update(dt)
    
    -- if left mouse is pressed, set current tile to position
    if love.mouse.isDown(1) and love.mouse.getY() > G_TOPBAR_HEIGHT + 2 * G_TOPBAR_PAD and not editorHandler:mouseIsOnMenu() and love.mouse.getX() < screen.w - 85 then
        local mx, my = camera:mousepos()
        local tx = math.floor(mx / C_TILE_SIZE)
        local ty = math.floor(my / C_TILE_SIZE)
        if isNewTile(tx, ty) then
            local brush = brushHandler.currentBrushId()
            if brush == -1 or love.keyboard.isDown(KEY_EDITOR_DELETE) then
                game.map:deleteTile(tx, ty)
            elseif brush == -2 then
                game.map:toggleWalkable(tx, ty)
            elseif brush == -3 then
                editorHandler:addEvent(tx, ty)
            elseif brush == -4 then
                game.map:toggleSpawn(tx, ty)
            elseif brush == -5 then
                editorHandler:addNpc(tx, ty)
            elseif brush == -6 then
                editorHandler:placeTransition(tx, ty)
            elseif brush == -7 then    
                game.map:delObj(tx, ty)
            elseif brush == -8 then
                editorHandler:singleTilePlacement(tx, ty)
            elseif brush == -9 then
                editorHandler:selection(tx, ty)
            elseif brush == -10 then
                editorHandler:elevate(tx, ty)
            else
                local brush = brushHandler.getCurrentBrush()
                if brush then 
                    if brush:isObjectBrush() then
                        mapHelper:createObject(tx, ty, brush)
                    else
                        game.map:setTile(tx, ty, brush:getTile(), brush:getTile2(), brush:getObject(), brush:getOverlay(), brush.blocking, brush.event)
                        if brush.border then
                            for x=-1,1 do
                                for y=-1,1 do
                                    if not (x == 0 and y == 0) then
                                        mapHelper:createBorder(tx+x, ty+y, brush)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


function st_edit:draw()
    
    -- take into account if the screen has changed
    screen:update()
    
    -- clear spritebatches and draw tiles to batch
    for i,atlas in pairs(brushHandler.getAtlanti()) do
        atlas:clear()
    end
    game.map:draw()
    
    -- draw stored spritebatch operations by camera offset by layers
    camera:attach()
    local layer = editorHandler:getLayerToggles()
    if layer.block then
        game.map:draw(true)
    end
    if layer.floor1 then
        for i,atlas in ipairs(brushHandler.getAtlanti()) do
            love.graphics.draw(atlas.batch_floor)
        end
    end
    if layer.floor2 then
        for i,atlas in ipairs(brushHandler.getAtlanti()) do
            love.graphics.draw(atlas.batch_floor2)
        end
    end
    if layer.object then
        for i,atlas in ipairs(brushHandler.getAtlanti()) do
            love.graphics.draw(atlas.batch_object)
        end
    end
    for id,entity in pairs(game.map.entities) do
        entity:draw()
    end
    if layer.overlay then
        for i,atlas in ipairs(brushHandler.getAtlanti()) do
            love.graphics.draw(atlas.batch_overlay)
        end
    end
    
    -- draw brush preview
    if not editorHandler:menuOpen() then
        
        if brushHandler.currentBrushId() > 0 and brushHandler.getCurrentBrush() then
            local tx, ty = drawHelper:tileCoords(love.mouse.getPosition())
            local brush = brushHandler.getCurrentBrush()
            if brush:isObjectBrush() then
                love.graphics.setColor(Color.RED)
                love.graphics.rectangle("fill", tx * C_TILE_SIZE, ty * C_TILE_SIZE, brush.xsize * C_TILE_SIZE, brush.ysize * C_TILE_SIZE)
            else
                brush:drawPreview(tx * C_TILE_SIZE, ty * C_TILE_SIZE)
            end
            love.graphics.setColor(Color.WHITE)
        else
            local selection = editorHandler:getSelection()
            if brushHandler.currentBrushId() == -9 and selection then
                love.graphics.setColor(Color.RED)
                local mx, my = drawHelper:tileCoords(love.mouse.getPosition())
                love.graphics.rectangle("fill", math.min(mx, selection.x) * C_TILE_SIZE, math.min(my, selection.y) * C_TILE_SIZE, (math.abs(mx - selection.x) + 1) * C_TILE_SIZE, (math.abs(my - selection.y) + 1) * C_TILE_SIZE)
            end
        end
        
    end
    
    love.graphics.setColor(Color.WHITE)
    
    -- draw walkable and event tile overlays if enabled
    drawHelper:drawToggles(editorHandler:showEvents(), editorHandler:showWalkable())
    
    -- draw event tooltip if toggled
    if editorHandler:showEvents() then
        editorHandler:drawEventTooltip()
    end
    editorHandler:drawNpcTooltip()
    
    camera:detach()
    
    -- draw toolbar/menu backgrounds
    if editorHandler:menuOpen() then
        drawHelper:greyOut()
    else
        drawHelper:toolbarBkg()
    end
    
    -- draw hud
    Gui.core.draw()
end


-- released instead of pressed to avoid an issue where
-- gui elements where clicked that appeared after the click
function st_edit:mousereleased(x, y, button, istouch)
    editorHandler:mousepressed(x, y, button, istouch)
end


-- key pressed had some issues with gui element ordering
-- -> released is used as can be seen above
-- however, mousewheel has no released action so we need to 
-- handle them extra
function st_edit:mousepressed(x, y, button, istouch)
    lastTile = {-1000, -1000} -- so that we can repeatedly click the last tile
end


function st_edit:wheelmoved( x, y )
    if not (y == 0) then
        local mx, my = love.mouse.getPosition()
        local button = "wu"
        if y < 0 then button = "wd" end
        editorHandler:mousepressed(mx, my, button, false)
    end
end


function st_edit:keypressed(key, scancode, isrepeat)    
    if not editorHandler:catchKey(key, isrepeat) then
        if key == "left" then camera:move(-C_CAM_SPEED, 0) end
        if key == "up" then camera:move(0, -C_CAM_SPEED) end
        if key == "right" then camera:move(C_CAM_SPEED, 0) end
        if key == "down" then camera:move(0, C_CAM_SPEED) end
        if key == "escape" then Gamestate.switch(st_menu_main) end
        local layer = editorHandler:getLayerToggles()
        if key == "1" then layer.floor1 = not layer.floor1 end
        if key == "2" then layer.floor2 = not layer.floor2 end
        if key == "3" then layer.object = not layer.object end
        if key == "4" then layer.overlay = not layer.overlay end
    end
end


function st_edit:loadMap(name)
    if love.filesystem.isFile( C_MAP_MASTER..name..C_MAP_SUFFIX ) then
        game.map = maploader:read( C_MAP_MASTER, name..C_MAP_SUFFIX )
    else
        log:msg("error", "Error loading map", C_MAP_MASTER..name..C_MAP_SUFFIX)
    end
end


function st_edit:newMap()
    local name = "unnamed"
    if love.filesystem.isFile( C_MAP_MASTER..name..C_MAP_SUFFIX ) then
        local i = 1
        while love.filesystem.isFile( C_MAP_MASTER..name..tostring(i)..C_MAP_SUFFIX ) do
            i = i + 1
        end
        name = name..tostring(i)
    end
    game.map = Map(name)
    game.map:createBlock(0, 0)
end


function st_edit:saveMap()
    game.map.name = editorHandler:getMapName()
    maploader:save(game.map, C_MAP_MASTER)
    self:reloadMap(game.map.name)
end


function st_edit:saveSettings()
    local file = love.filesystem.newFile("editor.settings")
    if file then
        file:open("w")
        if not brushHandler.getCurrentBrush() or (brushHandler.getCurrentBrush():isObjectBrush() and brushHandler.getCurrentBrush().copy) then
            file:write(tostring(1).."\n")
        else
            file:write(brushHandler.currentBrushId().."\n")
        end
        file:write(tostring(editorHandler:showWalkable()).."\n")
        file:write(tostring(editorHandler:showEvents()).."\n")
        file:write(tostring(game.map.name).."\n")
        local isFirst = true
        for i,k in ipairs(brushHandler.getRecentBrushes()) do
            if isFirst then
                isFirst = false
            else
                file:write(';')
            end
            file:write(k)
        end
        file:write("\n")
        for i,brush in ipairs(brushHandler.getBrushes()) do
            if not (brush:isObjectBrush() and brush.copy) then file:write(brush:toLine().."\n") end
        end
    else
        log:msg("error", "Failed creating file editor.settings")
    end
end


function st_edit:loadSettings()
    local file = love.filesystem.newFile("editor.settings")
    local result = file:open("r")
    if result then
        local i = 1
        local last = {}
        local cleared = false
        for line in file:lines() do
            if i == 1 then
                brushHandler.selectBrush(tonumber(line))
            elseif i == 2 then
                editorHandler:setWalkable(line == "true")
            elseif i == 3 then
                editorHandler:setEvents(line == "true")
            elseif i == 4 then
                st_edit:loadMap(line)
            elseif i == 5 then
                for k,j in ipairs(line:split(';')) do
                    table.insert(last, tonumber(j))
                end
            else
                if not cleared then 
                    brushHandler.clear()
                    cleared = true
                end
                local brush = Brush(0)
                brush:fromLine(line)
                brushHandler.setBrush(brush, brush.id)
            end
            i = i + 1
        end
        brushHandler.setRecentBrushes(last)
    else
        log:msg("verbose", "Could not find editor.settings")
    end
end


-- called when leaving state
function st_edit:leave()
    self:saveMap()
    self:saveSettings()
    tilesetPacker.pack()
end


-- called when state active and game exits
function st_edit:quit()
    self:leave()
end

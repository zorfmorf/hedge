
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
        if love.filesystem.isFile(C_MAP_MASTER..item) then
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
    
    editorHandler:update(dt)
    
    -- if left mouse is pressed, set current tile to position
    if love.mouse.isDown("l") and love.mouse.getY() > G_TOPBAR_HEIGHT + 2 * G_TOPBAR_PAD and not editorHandler:mouseIsOnMenu() then
        local mx, my = camera:mousepos()
        local tx = math.floor(mx / C_TILE_SIZE)
        local ty = math.floor(my / C_TILE_SIZE)
        if isNewTile(tx, ty) then
            local brush = brushHandler.currentBrushId()
            if brush == -1 then
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
    for i,atlas in ipairs(brushHandler.getAtlanti()) do
        love.graphics.draw(atlas.batch_floor)
    end
    for i,atlas in ipairs(brushHandler.getAtlanti()) do
        love.graphics.draw(atlas.batch_floor2)
    end
    for i,atlas in ipairs(brushHandler.getAtlanti()) do
        love.graphics.draw(atlas.batch_object)
    end
    for id,entity in pairs(game.map.entities) do
        entity:draw()
    end
    for i,atlas in ipairs(brushHandler.getAtlanti()) do
        love.graphics.draw(atlas.batch_overlay)
    end
    
    -- draw brush preview
    if not editorHandler:menuOpen() and brushHandler.currentBrushId() > 0 and brushHandler.getCurrentBrush() then
        local tx, ty = drawHelper:tileCoords(love.mouse.getPosition())
        brushHandler.getCurrentBrush():drawPreview(tx * C_TILE_SIZE, ty * C_TILE_SIZE)
    end
    
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
function st_edit:mousereleased(x, y, button)
    editorHandler:mousepressed(x, y, button)
end


-- key pressed had some issues with gui element ordering
-- -> released is used as can be seen above
-- however, mousewheel has no released action so we need to 
-- handle them extra
function st_edit:mousepressed(x, y, button)
    lastTile = {-1000, -1000} -- so that we can repeatedly click the last tile
    if button == "wd" or button == "wu" then
        editorHandler:mousepressed(x, y, button)
    end
end


function st_edit:keypressed(key, isrepeat)    
    if not editorHandler:catchKey(key, isrepeat) then
        if key == "left" then camera:move(-C_CAM_SPEED, 0) end
        if key == "up" then camera:move(0, -C_CAM_SPEED) end
        if key == "right" then camera:move(C_CAM_SPEED, 0) end
        if key == "down" then camera:move(0, C_CAM_SPEED) end
        if key == "escape" then Gamestate.switch(st_menu_main) end
        if tonumber(key) then
            local number = tonumber(key)
            if love.keyboard.isDown("lctrl") then
                number = number * (-1)
            end
            if brushHandler.getBrush(number) or (number < 0 and number > -8) then
                brushHandler.selectBrush(number)
            end
        end
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
        file:write(brushHandler.currentBrushId().."\n")
        file:write(tostring(editorHandler:showWalkable()).."\n")
        file:write(tostring(editorHandler:showEvents()).."\n")
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
            file:write(brush:toLine().."\n")
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
end


-- called when state active and game exits
function st_edit:quit()
    self:leave()
end


require "events.eventHandler"
require "view.hud_edit"
require "view.drawHelper"

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
    self:loadSettings()
    
    camera = Camera(0, 0)
    
end


function st_edit:update(dt)
    
    hud_edit:update(dt)
    
    -- if left mouse is pressed, set current tile to position
    if love.mouse.isDown("l") and love.mouse.getY() > G_TOPBAR_HEIGHT + 2 * G_TOPBAR_PAD and not hud_edit:mouseIsOnMenu() then
        local mx, my = camera:mousepos()
        local tx = math.floor(mx / C_TILE_SIZE)
        local ty = math.floor(my / C_TILE_SIZE)
        if isNewTile(tx, ty) then
            if game.brush == -1 then
                game.map:deleteTile(tx, ty)
            elseif game.brush == -2 then
                game.map:toggleWalkable(tx, ty)
            elseif game.brush == -3 then
                hud_edit:deleteEvent(tx, ty)
            elseif game.brush == -4 then
                hud_edit:spawnEvent(tx, ty)
            elseif game.brush == -5 then
                hud_edit:spawnNpc(tx, ty)
            else
                local brush = game:getCurrentBrush()
                if brush then game.map:setTile(tx, ty, brush:getTile(), brush:getObject(), brush:getOverlay(), brush.blocking, brush.event) end
            end
        end
    end
end


function st_edit:draw()
    
    -- take into account if the screen has changed
    screen:update()
    
    -- clear spritebatches and draw tiles to batch
    for i,atlas in pairs(game.atlanti) do
        atlas:clear()
    end
    game.map:draw()
    
    -- draw stored spritebatch operations by camera offset by layers
    camera:attach()
    for i,atlas in ipairs(game.atlanti) do
        love.graphics.draw(atlas.batch_floor)
    end
    for i,atlas in ipairs(game.atlanti) do
        love.graphics.draw(atlas.batch_object)
    end
    for id,entity in pairs(game.map.entities) do
        entity:draw()
    end
    for i,atlas in ipairs(game.atlanti) do
        love.graphics.draw(atlas.batch_overlay)
    end
    
    -- draw walkable and event tile overlays if enabled
    drawHelper:drawToggles(hud_edit:showEvents(), hud_edit:showWalkable())
    
    -- draw event tooltip if toggled
    if hud_edit:showEvents() then
        hud_edit:drawEventTooltip()
    end
    hud_edit:drawNpcTooltip()
    
    camera:detach()
    
    -- draw toolbar/menu backgrounds
    if hud_edit:menuOpen() then
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
    hud_edit:mousepressed(x, y, button)
end


-- key pressed had some issues with gui element ordering
-- -> released is used as can be seen above
-- however, mousewheel has no released action so we need to 
-- handle them extra
function st_edit:mousepressed(x, y, button)
    lastTile = {-1000, -1000} -- so that we can repeatedly click the last tile
    if button == "wd" or button == "wu" then
        hud_edit:mousepressed(x, y, button)
    end
end


function st_edit:keypressed(key, isrepeat)    
    if not hud_edit:catchKey(key, isrepeat) then
        if key == "left" then camera:move(-C_CAM_SPEED, 0) end
        if key == "up" then camera:move(0, -C_CAM_SPEED) end
        if key == "right" then camera:move(C_CAM_SPEED, 0) end
        if key == "down" then camera:move(0, C_CAM_SPEED) end
        if key == "escape" then Gamestate.switch(st_menu_main) end
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
    game.map.name = hud_edit:getMapName()
    maploader:save(game.map, C_MAP_MASTER)
    self:reloadMap(game.map.name)
end


function st_edit:saveSettings()
    local file = love.filesystem.newFile("editor.settings")
    if file then
        file:open("w")
        file:write(game.brush.."\n")
        file:write(tostring(hud_edit:showWalkable()).."\n")
        file:write(tostring(hud_edit:showEvents()).."\n")
        for i,brush in ipairs(game.brushes) do
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
        for line in file:lines() do
            if i == 1 then
                game.brush = tonumber(line)
            elseif i == 2 then
                hud_edit:setWalkable(line == "true")
            elseif i == 3 then
                hud_edit:setEvents(line == "true")
            else
                local brush = Brush(i - 3)
                brush:fromLine(line)
                game.brushes[i - 3] = brush
            end
            i = i + 1
        end
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

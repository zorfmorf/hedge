
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


function st_edit:enter()
    
    game:init()
    
    camera = Camera(0, 0)
    
end


function st_edit:update(dt)
    
    hud_edit:update(dt)
    
    -- if left mouse is pressed, set current tile to position
    if love.mouse.isDown("l") and love.mouse.getY() > G_TOPBAR_HEIGHT + 2 * G_TOPBAR_PAD and not hud_edit:menuIsOpen() then
        local mx, my = camera:mousepos()
        local tx = math.floor(mx / C_TILE_SIZE)
        local ty = math.floor(my / C_TILE_SIZE)
        if isNewTile(tx, ty) then
            if game.brush == -1 then
                game.map:deleteTile(tx, ty)
            elseif game.brush == -2 then
                game.map:toggleWalkable(tx, ty)
            else
                local brush = game:getCurrentBrush()
                if brush then game.map:setTile(tx, ty, brush:getTile(), brush:getObject(), brush:getOverlay(), brush.blocking) end
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
    for i,atlas in ipairs(game.atlanti) do
        love.graphics.draw(atlas.batch_overlay)
    end
    
    -- draw walkable and event tile overlays if enabled
    drawHelper:drawToggles(hud_edit:showEvents(), hud_edit:showWalkable())
    camera:detach() 
    
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
    end
end


-- called when leaving state
function st_edit:leave()
    maploader:save(game.map)
end


-- called when state active and game exits
function st_edit:quit()
    st_edit:leave()
end


require "view.hud_edit"

st_edit = {}

local camera = nil


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
        local brush = game:getCurrentBrush()
        if brush then game.map:setTile(tx, ty, brush:getTile(), brush:getObject(), brush:getOverlay(), brush:getBlocking()) end
    end
end


function st_edit:draw()
    
    -- take into account if the screen has changed
    screen:update()
    
    -- clear spritebatches and draw tiles to batch
    for i,atlas in pairs(game.atlanti) do
        atlas.batch:clear()
    end
    game.map:draw(camera)
    
    -- draw stored spritebatch operations by camera offset
    camera:attach()
    for i,atlas in ipairs(game.atlanti) do
        love.graphics.draw(atlas.batch)
    end
    camera:detach()
    
    -- draw hud
    Gui.core.draw()
end


function st_edit:mousepressed(x, y, button)
    hud_edit:mousepressed(x, y, button)
end


function st_edit:keypressed(key, isrepeat)
    
    Gui.keyboard.pressed(key)
    
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

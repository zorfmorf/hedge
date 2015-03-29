
st_edit = {}

local map = nil -- map information
local atlanti = nil -- set of texture atlanti
local camera = nil
local sTile = { 1, 22, 5 } -- current selected tile


function st_edit:enter()
    
    Gui.core.style = require "view.style"
    
    atlanti = tilesetreader:read()
    map = maploader:read()
    map:setTile(0, 0, sTile[1], sTile[2], sTile[3])
    
    camera = Camera(0, 0)
end


function st_edit:update(dt)
    
    -- top toolbar
    Gui.group.push{ grow = "right", pos = { 0, 0 }, size = {screen.w, G_TOPBAR_HEIGHT}, pad = G_TOPBAR_PAD, bkg = true }
        Gui.Button{ text = "Save", size = {100} }
        Gui.Button{ text = "Options", size = {100} }
        Gui.Button{ text = "Quit", size = {100} }
        Gui.Label{ text = "FPS: " .. love.timer.getFPS() }
    Gui.group.pop{}
    
    -- expandable bottom right tile selector
    Gui.group.push{ grow = "up", pos = { screen.w - 100, screen.h - 50}, bkg = true }
        Gui.Button{ text = "T", size = { "tight" } }
        Gui.Button{ text = "P", size = { "tight" } }
    Gui.group.pop{}
    
    -- if left mouse is pressed, set current tile to position
    if love.mouse.isDown("l") and love.mouse.getY() > G_TOPBAR_HEIGHT + 2 * G_TOPBAR_PAD then
        local mx, my = camera:mousepos()
        local tx = math.floor(mx / C_TILE_SIZE)
        local ty = math.floor(my / C_TILE_SIZE)
        map:setTile(tx, ty, sTile[1], sTile[2], sTile[3])
    end
end


function st_edit:draw()
    
    -- take into account if the screen has changed
    screen:update()
    
    -- clear spritebatches and draw tiles to batch
    for i,atlas in pairs(atlanti) do
        atlas.batch:clear()
    end
    map:draw(camera)
    
    -- draw stored spritebatch operations by camera offset
    camera:attach()
    for i,atlas in ipairs(atlanti) do
        love.graphics.draw(atlas.batch)
    end
    camera:detach()
    
    -- draw hud
    Gui.core.draw()
end


function st_edit:mousepressed(x, y, button)
    if button == "l" and y > G_TOPBAR_HEIGHT + 2 * G_TOPBAR_PAD then
        local wx, wy = camera:worldCoords(x, y)
        map:setTile(math.floor(wx / C_TILE_SIZE), math.floor(wy / C_TILE_SIZE), 1, 22, 5)
    end
end


function st_edit:keypressed(key, isrepeat)
    if key == "left" then camera:move(-C_CAM_SPEED, 0) end
    if key == "up" then camera:move(0, -C_CAM_SPEED) end
    if key == "right" then camera:move(C_CAM_SPEED, 0) end
    if key == "down" then camera:move(0, C_CAM_SPEED) end
end

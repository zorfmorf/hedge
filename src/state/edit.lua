
st_edit = {}

local map = nil -- map information
local atlanti = nil -- set of texture atlanti
local camera = nil


function st_edit:enter()
    atlanti = tilesetreader:read()
    map = maploader:read()
    map:setTile(0, 0, 1, 22, 5)
    
    camera = Camera(0, 0)
end


function st_edit:update(dt)
    
end


function st_edit:draw()
    
    -- clear spritebatches and draw tiles to batch
    for i,atlas in pairs(atlanti) do
        atlas.batch:clear()
    end
    map:draw()
    
    -- draw stored spritebatch operations by camera offset
    camera:attach()
    for i,atlas in ipairs(atlanti) do
        love.graphics.draw(atlas.batch)
    end
    camera:detach()
    
    -- draw hud
    love.graphics.print(love.timer.getFPS(), screen.w - 100, 10)
end


function st_edit:mousepressed(x, y, button)
    if button == "l" then
        local wx, wy = camera:worldCoords(x, y)
        map:setTile(math.floor(wx / C_TILE_SIZE), math.floor(wy / C_TILE_SIZE), 1, 22, 5)
    end
end


drawHelper = {}

-- convert screen coordinates to tile coordinates
function drawHelper:tileCoords(x, y)
    local nx, ny = camera:worldCoords(x, y)
    return math.floor(nx / C_TILE_SIZE), math.floor(ny / C_TILE_SIZE)
end


-- 
function drawHelper:drawToggles(events, walkable)
    local sx, sy = drawHelper:tileCoords(0, 0)
    local ex, ey = drawHelper:tileCoords(screen.w, screen.h)
    
    for x = sx, ex do
        for y = sy, ey do
            local tile = game.map:getTile(x, y)
            if tile then
                if walkable and not tile.block then
                    love.graphics.setColor(Color.FADE)
                    love.graphics.rectangle("fill", x * C_TILE_SIZE, y * C_TILE_SIZE, C_TILE_SIZE, C_TILE_SIZE)
                end
                if events and tile.event then
                    love.graphics.setColor(Color.RED)
                    love.graphics.rectangle("fill", x * C_TILE_SIZE, y * C_TILE_SIZE, C_TILE_SIZE, C_TILE_SIZE)
                end
            end
        end
    end
    love.graphics.setColor(255, 255, 255, 255)
end


-- grey out everything on the screen
function drawHelper:greyOut()
    love.graphics.setColor(Color.GREY)
    love.graphics.rectangle("fill", 0, 0, screen.w, screen.h)
    love.graphics.setColor(Color.WHITE)
end

-- tool menu background
function drawHelper:toolbarBkg()
    love.graphics.setColor(Color.GREY)
    love.graphics.rectangle("fill", 0, screen.h - C_TILE_SIZE, screen.w, C_TILE_SIZE)
    love.graphics.setColor(Color.WHITE)
end
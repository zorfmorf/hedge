
local location_icon = love.graphics.newImage("img/icon/position-marker.png")
local font = love.graphics.newFont("font/alagard.ttf", 15)
local img = {}
img.date = love.graphics.newImage("img/ui/datetime.png")

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
    
    -- draw events and walkable fields
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
    
    -- draw spawns
    for key,value in pairs(game.map.spawns) do
        love.graphics.setColor(Color.FADE)
        love.graphics.draw(location_icon, value.x * C_TILE_SIZE, value.y * C_TILE_SIZE)
        love.graphics.setColor(Color.RED_HARD)
        love.graphics.print(key, value.x * C_TILE_SIZE, value.y * C_TILE_SIZE)
    end
    
    -- draw 0,0 position (default spawn)
    love.graphics.setColor(Color.RED_HARD)
    love.graphics.rectangle("line", 0, 0, C_TILE_SIZE, C_TILE_SIZE)
    love.graphics.setColor(Color.WHITE)
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


function drawHelper:update(dt)
    self.targetTimeFactor = timeHandler.getTimeFactor()
    if self.targetTimeFactor > 13 then self.targetTimeFactor = 13 - (self.targetTimeFactor - 13) end
    if not self.currentTimeFactor then self.currentTimeFactor = self.targetTimeFactor end
    local diff = self.targetTimeFactor - self.currentTimeFactor
    self.currentTimeFactor = self.currentTimeFactor + diff * math.min(1, dt)
end


-- day/evening/night effect
function drawHelper:dayCycle()
    local x = math.min(190, ((self.currentTimeFactor - 15)^2) * 1.5)
    love.graphics.setColor(4, 37, 70, math.floor(x))
    love.graphics.rectangle("fill", 0, 0, screen.w, screen.h)
    love.graphics.setColor(Color.WHITE)
end


function drawHelper:timeAndDate()
    love.graphics.setColor(Color.WHITE)
    love.graphics.draw(img.date, screen.w - img.date:getWidth() - 5, 5)
    love.graphics.setFont(font)
    local str = timeHandler.tostr()
    love.graphics.setColor(Color.BLACK)
    love.graphics.print(str, screen.w - (font:getWidth(str) + 20), 15)
    love.graphics.setColor(Color.WHITE)
    love.graphics.print(str, screen.w - (font:getWidth(str) + 19), 16)
end

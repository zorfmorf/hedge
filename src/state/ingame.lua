
require "events.eventHandler"
require "view.animationHelper"

st_ingame = {}

camera = nil

-- place player at specified spawnId or at first or at origin
local function placePlayer(spawnId)
    for i,value in pairs(game.map.spawns) do
        if i == spawnId then
            player:place(value.x, value.y)
            return
        end
    end
    if game.map.spawns[1] then
        player:place(game.map.spawns[1].x, game.map.spawns[1].y)
        return
    end
    player:place(0, 0)
end


function st_ingame:enter()
    
    eventHandler:init()
    animationHelper.init()
    game:init(true)
    
    camera = Camera(0, 0)
    
    player = Player()
    
    self.entities = {}
    self.entities[player.id] = player
    
    placePlayer(1)
end

function st_ingame:update(dt)
    for id,entity in pairs(self.entities) do
        entity:update(dt)
    end
end


function st_ingame:draw()
        
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
    for id,entity in pairs(self.entities) do
        entity:draw()
    end
    for i,atlas in ipairs(game.atlanti) do
        love.graphics.draw(atlas.batch_overlay)
    end
    
    
    camera:detach()
    
    -- draw hud
    Gui.core.draw()
end


function st_ingame:keypressed(key, isrepeat)
    if key == KEY_LEFT then player:move("left") end
    if key == KEY_RIGHT then player:move("right") end
    if key == KEY_DOWN then player:move("down") end
    if key == KEY_UP then player:move("up") end
end


function st_ingame:keyreleased(key)
    if key == KEY_LEFT then player:unmove("left") end
    if key == KEY_RIGHT then player:unmove("right") end
    if key == KEY_DOWN then player:unmove("down") end
    if key == KEY_UP then player:unmove("up") end
end

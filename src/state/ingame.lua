
require "events.eventHandler"
require "view.animationHelper"

st_ingame = {}

camera = nil

-- place player at specified spawnId or at first or at origin
function st_ingame:placePlayer(spawnId)
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
    
    log:msg("verbose", "Entering game state")
    
    eventHandler:init()
    animationHelper.init()
    game:init(false)
    self.menu = Menu()
    
    camera = Camera(0, 0)
    
    if not game.map.entities[player.id] then
        st_ingame:placePlayer(1)
        game.map.entities[player.id] = player
    end
end


function st_ingame:startDialog(dialog)
    self.dialog = dialog
end


function st_ingame:update(dt)
    if self.menu:isOpen() then
        self.menu:update(dt)
    else
        if self.dialog then
            if self.dialog:isFinished() then self.dialog = nil end
        else
            for id,entity in pairs(game.map.entities) do
                entity:update(dt)
            end
        end
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
    for i,entity in pairs(game.map.sortedEntities) do
        entity:draw()
    end
    for i,atlas in ipairs(game.atlanti) do
        love.graphics.draw(atlas.batch_overlay)
    end
    
    camera:detach()
    
    if self.dialog then self.dialog:draw() end
    
    if self.menu:isOpen() then self.menu:draw() end
    
    -- draw hud
    Gui.core.draw()
    love.graphics.print(math.floor(love.timer.getFPS()), screen.w - 50, 5)
end


function st_ingame:keypressed(key, isrepeat)
    if self.menu:isOpen() then
        self.menu:keypressed(key, isrepeat)
    else
        if self.dialog then
            if key == KEY_USE then self.dialog:advance() end
            if key == KEY_UP then self.dialog:up() end
            if key == KEY_DOWN then self.dialog:down() end
        else
            if key == KEY_LEFT and not isrepeat then player:move("left") end
            if key == KEY_RIGHT and not isrepeat then player:move("right") end
            if key == KEY_DOWN and not isrepeat then player:move("down") end
            if key == KEY_UP and not isrepeat then player:move("up") end
            if key == KEY_USE then player:use() end
        end
        if key == "escape" and not self.dialog then
            self.menu:open()
        end
    end
end


function st_ingame:keyreleased(key)
    if self.menu:isOpen() then
        
    else
        if self.dialog then
            
        else
            if key == KEY_LEFT then player:unmove("left") end
            if key == KEY_RIGHT then player:unmove("right") end
            if key == KEY_DOWN then player:unmove("down") end
            if key == KEY_UP then player:unmove("up") end
        end
    end
end

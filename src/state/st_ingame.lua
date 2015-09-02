
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
    
    st_ingame:updateCamera()
end


function st_ingame:startDialog(dialog)
    local d = dialogHandler.get(dialog)
    if d then
        d:ready()
        self.dialog = d
    else
        log:msg("error", "Dialog not found:", dialog)
    end
end


function st_ingame:update(dt)
    
    -- open menus trump all
    if self.menu:isOpen() then
        self.menu:update(dt)
        return
    end
    
    -- transition effects block everything else
    if self.transition then
        self.transition:update(dt)
        if self.transition:isFinished() then
            if self.transition.style == "fade_out" then
                self.transition = Transition("fade_in")
            else
                self.transition = nil
            end
        end
        return
    end
    
    -- dialog block entity updates
    if self.dialog then
        if self.dialog:isFinished() then self.dialog = nil end
        return
    end
    
    -- default entity updates
    for id,entity in pairs(game.map.entities) do
        entity:update(dt)
    end
    
    -- update camera
    st_ingame:updateCamera()
    
    -- update time
    timeHandler.update(dt)
    
    -- draw helper needs to update daylight factors based on time and dt
    drawHelper:update(dt)
end


function st_ingame:updateCamera()
    local x = player.posd.x * C_TILE_SIZE
    local y = player.posd.y * C_TILE_SIZE
    
    local min = game.map.bound.min
    local max = game.map.bound.max
    
    -- adjust camera max and min dependent on map boundary
    -- do this only if the map is larger than the screen
    if (max.x - min.x) * C_TILE_SIZE > screen.w and (max.y - min.y) * C_TILE_SIZE > screen.h then
        if x - screen.w * 0.5 < min.x * C_TILE_SIZE then x = min.x * C_TILE_SIZE +  screen.w * 0.5 end
        if y - screen.h * 0.5 < min.y * C_TILE_SIZE then y = min.y * C_TILE_SIZE +  screen.h * 0.5 end
        if x + screen.w * 0.5 > (max.x + 1) * C_TILE_SIZE then x = (max.x + 1) * C_TILE_SIZE -  screen.w * 0.5 end
        if y + screen.h * 0.5 > (max.y + 1) * C_TILE_SIZE then y = (max.y + 1) * C_TILE_SIZE -  screen.h * 0.5 end
    end
    
    camera:lookAt(math.floor(x), math.floor(y))
end


function st_ingame:draw()
        
    -- take into account if the screen has changed
    screen:update()
    
    -- clear spritebatches and draw tiles to batch
    game.atlas:clear()
    game.map:draw()
    
    -- draw stored spritebatch operations by camera offset by layers
    camera:attach()
    
    love.graphics.setColor(Color.WHITE)
    love.graphics.draw(game.atlas.batch_floor)
    love.graphics.draw(game.atlas.batch_floor2)
    love.graphics.draw(game.atlas.batch_object)
    for i,entity in pairs(game.map.sortedEntities) do
        entity:draw()
    end
    love.graphics.draw(game.atlas.batch_overlay)
    
    camera:detach()
    
    if game.map:getSetting("simulate_day") then drawHelper:dayCycle() end
    
    if self.dialog then
        self.dialog:draw()
    else
        drawHelper:timeAndDate()
    end
    
    inventory:draw()
    
    if self.transition then self.transition:draw() end
    
    if self.menu:isOpen() then self.menu:draw() end
        
    -- draw hud
    Gui.core.draw()
    
    love.graphics.print(love.timer.getFPS(), 5, 5)
end


function st_ingame:keypressed(key, isrepeat)
    if self.menu:isOpen() then
        self.menu:keypressed(key, isrepeat)
    elseif self.transition then
    
    elseif self.dialog then
        if key == KEY_USE then self.dialog:advance() end
        if key == KEY_UP then self.dialog:up() end
        if key == KEY_DOWN then self.dialog:down() end
    else
        if key == "t" then timeHandler.addTime(60) end -- TODO: remove
        if key == KEY_LEFT and not isrepeat then player:move("left") end
        if key == KEY_RIGHT and not isrepeat then player:move("right") end
        if key == KEY_DOWN and not isrepeat then player:move("down") end
        if key == KEY_UP and not isrepeat then player:move("up") end
        if key == KEY_USE then player:use() end
        if key == KEY_NEXT_TOOL then inventory:nextTool() end
        if key == KEY_PREVIOUS_TOOL then inventory:previousTool() end
        if key == KEY_INVENTORY then inventory:trigger() end
        if key == KEY_EXIT then
            if inventory.open then
                inventory:trigger(false)
            else
                self.menu:open()
            end
        end
    end
end


function st_ingame:keyreleased(key)
    if self.menu:isOpen() then
        
    elseif self.transition then
    
    elseif self.dialog then
            
    else
        if key == KEY_LEFT then player:unmove("left") end
        if key == KEY_RIGHT then player:unmove("right") end
        if key == KEY_DOWN then player:unmove("down") end
        if key == KEY_UP then player:unmove("up") end
    end
end

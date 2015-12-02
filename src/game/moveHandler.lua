
moveHandler = {}


local function canBeMovedTo(x, y)
    local tile = game.map:getTile(x, y)
    return tile and (not tile.block) and (not tile.npc)
end


local function handleMove(entity, direction, target)
    entity.dir = direction
    if canBeMovedTo( target.x, target.y ) then        
        game.map:removeEntity(entity.pos.x, entity.pos.y)
        entity.pos = { x=target.x, y=target.y }
        entity.walking = true
        game.map:addEntity(entity.pos.x, entity.pos.y, entity.id)
    else
        entity.walking = false
    end
end


local function move(entity, dt, xd, yd)
    local mod = 1
    if entity.id == 1 and love.keyboard.isDown(KEY_SPRINT) then
        mod = 2
    end
    if entity.id > 1 then mod = 0.5 end
    entity.posd.x = entity.posd.x + xd * dt * CHAR_MOVE * mod
    entity.posd.y = entity.posd.y + yd * dt * CHAR_MOVE * mod
    if (xd < 0 and entity.posd.x <= entity.pos.x) or
       (xd > 0 and entity.posd.x >= entity.pos.x) or
       (yd < 0 and entity.posd.y <= entity.pos.y) or
       (yd > 0 and entity.posd.y >= entity.pos.y) then
        entity.posd = { x=entity.pos.x, y=entity.pos.y }
        entity.walking = false
        local blocks = eventHandler.walkedOnTile(entity.pos)
        if not blocks then
            if entity.next then
                moveHandler.move(entity, entity.next)
            end
        end
    end
end


function moveHandler.update(entity, dt)
    
    -- if entity is walking, update its position
    if entity.walking then
        if entity.dir == "left" then move(entity, dt, -1, 0) end
        if entity.dir == "right" then move(entity, dt, 1, 0) end
        if entity.dir == "up" then move(entity, dt, 0, -1) end
        if entity.dir == "down" then move(entity, dt, 0, 1) end
    end
    
    -- if entity is on a change direction cooldown, check if cooldown is zero
    if entity.dircd then
        
        -- if the direction key is not pressed anymore, don't move
        if (entity.dir == "left" and not love.keyboard.isDown(KEY_LEFT)) or 
           (entity.dir == "up" and not love.keyboard.isDown(KEY_UP)) or
           (entity.dir == "right" and not love.keyboard.isDown(KEY_RIGHT)) or 
           (entity.dir == "down" and not love.keyboard.isDown(KEY_DOWN)) then
            entity.dircd = nil
            entity.next = nil
        else
            -- if the cooldown is zero, move
            entity.dircd = entity.dircd - dt
            if entity.dircd <= 0 then
                entity.dircd = nil
                moveHandler.move(entity, entity.dir)
            end
        end
    end
    
    -- set standstill flag if no movement key is pressed and is not walking
    if not love.keyboard.isDown(KEY_LEFT) and
       not love.keyboard.isDown(KEY_UP) and
       not love.keyboard.isDown(KEY_RIGHT) and
       not love.keyboard.isDown(KEY_DOWN) and
       not entity.walking then
        entity.standstill = true
    end
end


function moveHandler.move(entity, direction)
    entity.next = direction
    if not entity.walking then
        if not (entity.dir == direction) and entity.standstill then
            entity.dir = direction
            entity.dircd = CHAR_MOVE_DIRCHANGE_THRESHOLD
        else
            if direction == "left" then handleMove(entity, direction, { x=entity.pos.x-1, y=entity.pos.y}) end
            if direction == "right" then handleMove(entity, direction, { x=entity.pos.x+1, y=entity.pos.y}) end
            if direction == "down" then handleMove(entity, direction, { x=entity.pos.x, y=entity.pos.y+1}) end
            if direction == "up" then  handleMove(entity, direction, { x=entity.pos.x, y=entity.pos.y-1}) end
        end
    end
    entity.standstill = false
end


function moveHandler.unmove(entity, direction)
    entity.next = nil
end

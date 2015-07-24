
moveHandler = {}


local function canBeMovedTo(x, y)
    local tile = game.map:getTile(x, y)
    return tile and not tile.block and not tile.npc
end


local function handleMove(entity, direction, target)
    entity.dir = direction
    if canBeMovedTo( target.x, target.y ) then
        entity.target = target
        entity.next = direction
        
        -- update map
        game.map:removeEntity(entity.tile.x, entity.tile.y)
        entity.tile = target
        game.map:addEntity(entity.tile.x, entity.tile.y, entity.id)
    else
        entity.pos.x = entity.tile.x
        entity.pos.y = entity.tile.y
        entity.next = nil
    end
end


function moveHandler.update(entity, dt)
    if entity.dir == "left" then
        entity.pos.x = entity.pos.x - dt * CHAR_MOVE
        if entity.pos.x < entity.target.x then
            eventHandler.walkedOnTile(entity.target)
            if entity.next == "left" and love.keyboard.isDown(KEY_LEFT) then
                handleMove(entity, entity.next, { x=entity.target.x-1, y=entity.target.y})
            else
                entity.pos.x = entity.target.x
                entity.dir = nil
                if entity.next then entity:move(entity.next) end
            end
        end
    end
    if entity.dir == "right" then
        entity.pos.x = entity.pos.x + dt * CHAR_MOVE
        if entity.pos.x > entity.target.x then
            eventHandler.walkedOnTile(entity.target)
            if entity.next == "right" and love.keyboard.isDown(KEY_RIGHT)then
                handleMove(entity, entity.next, { x=entity.target.x+1, y=entity.target.y})
            else
                entity.pos.x = entity.target.x
                entity.dir = nil
                if entity.next then entity:move(entity.next) end
            end
        end
    end
    if entity.dir == "up" then
        entity.pos.y = entity.pos.y - dt * CHAR_MOVE
        if entity.pos.y < entity.target.y then
            eventHandler.walkedOnTile(entity.target)
            if entity.next == "up" and love.keyboard.isDown(KEY_UP) then
                handleMove(entity, entity.next, { x=entity.target.x, y=entity.target.y-1})
            else
                entity.pos.y = entity.target.y
                entity.dir = nil
                if entity.next then entity:move(entity.next) end
            end
        end
    end
    if entity.dir == "down" then
        entity.pos.y = entity.pos.y + dt * CHAR_MOVE
        if entity.pos.y > entity.target.y then
            eventHandler.walkedOnTile(entity.target)
            if entity.next == "down" and love.keyboard.isDown(KEY_DOWN) then
                handleMove(entity, entity.next, { x=entity.target.x, y=entity.target.y+1})
            else
                entity.pos.y = entity.target.y
                entity.dir = nil
                if entity.next then entity:move(entity.next) end
            end
        end
    end
end


function moveHandler.move(entity, direction)
    if entity.dir then
        entity.next = direction
    else
        if direction == "left" then handleMove(entity, direction, { x=entity.pos.x-1, y=entity.pos.y}) end
        if direction == "right" then handleMove(entity, direction, { x=entity.pos.x+1, y=entity.pos.y}) end
        if direction == "down" then handleMove(entity, direction, { x=entity.pos.x, y=entity.pos.y+1}) end
        if direction == "up" then  handleMove(entity, direction, { x=entity.pos.x, y=entity.pos.y-1}) end
    end
end


function moveHandler.unmove(entity, direction)
    if entity.next == direction then
        entity.next = nil
    end
end

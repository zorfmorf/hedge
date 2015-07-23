
moveHandler = {}


local function canBeMovedTo(x, y)
    local tile = game.map:getTile(x, y)
    return tile and not tile.block
end


local function handleMove(entity, direction, target)
    if canBeMovedTo( target.x, target.y ) then
        entity.target = target
        entity.dir = direction
        entity.next = direction
    end
end


function moveHandler.update(entity, dt)
    if entity.dir == "left" then
        entity.pos.x = entity.pos.x - dt * CHAR_MOVE
        if entity.pos.x < entity.target.x then
            if entity.next == "left" and love.keyboard.isDown(KEY_LEFT) and canBeMovedTo(entity.target.x-1, entity.target.y) then
                entity.target.x = entity.target.x - 1
            else
                entity.pos.x = entity.target.x
                entity.dir = nil
                entity:move(entity.next)
            end
        end
    end
    if entity.dir == "right" then
        entity.pos.x = entity.pos.x + dt * CHAR_MOVE
        if entity.pos.x > entity.target.x then
            if entity.next == "right" and love.keyboard.isDown(KEY_RIGHT) and canBeMovedTo(entity.target.x+1, entity.target.y) then
                entity.target.x = entity.target.x + 1
            else
                entity.pos.x = entity.target.x
                entity.dir = nil
                entity:move(entity.next)
            end
        end
    end
    if entity.dir == "up" then
        entity.pos.y = entity.pos.y - dt * CHAR_MOVE
        if entity.pos.y < entity.target.y then
            if entity.next == "up" and love.keyboard.isDown(KEY_UP) and canBeMovedTo(entity.target.x, entity.target.y-1) then
                entity.target.y = entity.target.y - 1
            else
                entity.pos.y = entity.target.y
                entity.dir = nil
                entity:move(entity.next)
            end
        end
    end
    if entity.dir == "down" then
        entity.pos.y = entity.pos.y + dt * CHAR_MOVE
        if entity.pos.y > entity.target.y then
            if entity.next == "down" and love.keyboard.isDown(KEY_DOWN) and canBeMovedTo(entity.target.x, entity.target.y+1) then
                entity.target.y = entity.target.y + 1
            else
                entity.pos.y = entity.target.y
                entity.dir = nil
                entity:move(entity.next)
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

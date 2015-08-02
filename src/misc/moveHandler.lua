
moveHandler = {}


local function canBeMovedTo(x, y)
    local tile = game.map:getTile(x, y)
    return tile and (not tile.block) and (not tile.npc)
end


local function handleMove(entity, direction, target)
    entity.dir = direction
    if canBeMovedTo( target.x, target.y ) then        
        game.map:removeEntity(entity.pos.x, entity.pos.y)
        entity.pos = { x=target.x, y=target.y}
        entity.walking = true
        game.map:addEntity(entity.pos.x, entity.pos.y, entity.id)
    else
        entity.walking = false
    end
end


local function move(entity, dt, xd, yd)
    entity.posd.x = entity.posd.x + xd * dt * CHAR_MOVE
    entity.posd.y = entity.posd.y + yd * dt * CHAR_MOVE
    if (xd < 0 and entity.posd.x <= entity.pos.x) or
       (xd > 0 and entity.posd.x >= entity.pos.x) or
       (yd < 0 and entity.posd.y <= entity.pos.y) or
       (yd > 0 and entity.posd.y >= entity.pos.y) then
        entity.posd = entity.pos
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
    if entity.walking then
        if entity.dir == "left" then move(entity, dt, -1, 0) end
        if entity.dir == "right" then move(entity, dt, 1, 0) end
        if entity.dir == "up" then move(entity, dt, 0, -1) end
        if entity.dir == "down" then move(entity, dt, 0, 1) end
    end
end


function moveHandler.move(entity, direction)
    entity.next = direction
    if not entity.walking then
        if direction == "left" then handleMove(entity, direction, { x=entity.pos.x-1, y=entity.pos.y}) end
        if direction == "right" then handleMove(entity, direction, { x=entity.pos.x+1, y=entity.pos.y}) end
        if direction == "down" then handleMove(entity, direction, { x=entity.pos.x, y=entity.pos.y+1}) end
        if direction == "up" then  handleMove(entity, direction, { x=entity.pos.x, y=entity.pos.y-1}) end
    end
end


function moveHandler.unmove(entity, direction)
    entity.next = nil
end

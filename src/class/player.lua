

Player = Class{}

function Player:init()
    self.id = 1 -- player always has id 1, only one player allowed at all times
    self.pos = { x=0, y=0 }
    self.dir = nil
    self.cycle = 0
    self.anim = 3
    self.name = "Player"
end


function Player:place(x, y)
    self.pos = { x=x, y=y } -- actual current position
    self.tile = { x=x, y=y } -- tile currently occupied
    if game.map then game.map:addEntity(x, y, self.id) end
end


function Player:use()
    local tile = nil
    if math.floor(self.pos.x) == self.pos.x and math.floor(self.pos.y) == self.pos.y then
        local target = {}
        target.x = self.pos.x
        target.y = self.pos.y
        if self.anim == 1 then target.y = target.y - 1 end
        if self.anim == 2 then target.x = target.x - 1 end
        if self.anim == 3 then target.y = target.y + 1 end
        if self.anim == 4 then target.x = target.x + 1 end
        tile = game.map:getTile(target.x, target.y)
    end
    if tile then
        if tile.npc and not(tile.npc == self.id) then game.map.entities[tile.npc]:use() end
        if not tile.npc and tile.event then eventHandler.triggerEvent(tile.event, false) end
    end
end


function Player:update(dt)
    animationHelper.update(self, dt)
    moveHandler.update(self, dt)
end


function Player:draw()
    animationHelper.draw(self)
end


function Player:move(direction)
    moveHandler.move(self, direction)
end


function Player:unmove(direction)
    moveHandler.unmove(self, direction)
end

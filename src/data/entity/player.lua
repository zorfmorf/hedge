

Player = Class{}

function Player:init()
    self.id = 1 -- player always has id 1, only one player allowed at all times
    self.name = "Player"
    
    -- pos/draw information
    self.pos = { x=0, y=0 } -- actual current position
    self.posd = { x=0, y=0 } -- draw position
    self.dir = "down" -- look direction
    self.walking = false -- if currently walking
    self.anim = 3 -- corresponding animation set
    self.next = nil -- queued movement
    self.cycle = 0 -- anim cycle
end


function Player:place(x, y)
    self.pos = { x=x, y=y }
    self.posd = { x=x, y=y }
    if game.map then game.map:addEntity(x, y, self.id) end
    if camera then st_ingame:updateCamera() end
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
    if not self.walking then
        if love.keyboard.isDown(KEY_LEFT) then self:move("left") end
        if love.keyboard.isDown(KEY_RIGHT) then self:move("right") end
        if love.keyboard.isDown(KEY_UP) then self:move("up") end
        if love.keyboard.isDown(KEY_DOWN) then self:move("down") end
    end
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

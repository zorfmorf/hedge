
local font = love.graphics.newFont("font/alagard.ttf", 15)

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
    
    -- floating texts
    self.floats = {}
end


function Player:place(x, y)
    self.pos = { x=x, y=y }
    self.posd = { x=x, y=y }
    if game.map then game.map:addEntity(x, y, self.id) end
    if camera then st_ingame:updateCamera() end
end


function Player:use()
    local tile = nil
    local tx = nil
    local ty = nil
    if math.floor(self.pos.x) == self.pos.x and math.floor(self.pos.y) == self.pos.y then
        local target = {}
        target.x = self.pos.x
        target.y = self.pos.y
        if self.anim == 1 then target.y = target.y - 1 end
        if self.anim == 2 then target.x = target.x - 1 end
        if self.anim == 3 then target.y = target.y + 1 end
        if self.anim == 4 then target.x = target.x + 1 end
        tile = game.map:getTile(target.x, target.y)
        tx = target.x
        ty = target.y
    end
    if tile then
        if tile.npc and not(tile.npc == self.id) then game.map.entities[tile.npc]:use() end
        if not tile.npc and tile.event then eventHandler.triggerEvent(tile.event, false, tx, ty) end
    end
end


function Player:update(dt)
    animationHelper.update(self, dt)
    moveHandler.update(self, dt)
    if not self.walking and not self.dircd then
        if love.keyboard.isDown(KEY_LEFT) then self:move("left") end
        if love.keyboard.isDown(KEY_RIGHT) then self:move("right") end
        if love.keyboard.isDown(KEY_UP) then self:move("up") end
        if love.keyboard.isDown(KEY_DOWN) then self:move("down") end
    end
    for i,float in ipairs(self.floats)do
        float.time = float.time + dt * CHAR_FLOAT_TIME
        if float.time > 1 then
            table.remove(self.floats, i)
        end
    end
end


function Player:draw()
    animationHelper.draw(self)
    love.graphics.setFont(font)
    for i,float in ipairs(self.floats) do
        love.graphics.setColor(0, 0, 0, math.max(0, math.floor(255 - (255 * float.time))))
        love.graphics.print(float.value, self.posd.x * C_TILE_SIZE + (C_TILE_SIZE / 2), self.posd.y * C_TILE_SIZE - math.floor(C_TILE_SIZE * float.time), 0, 1, 1, math.floor(font:getWidth(float.value) / 2), C_TILE_SIZE + 10)
        love.graphics.setColor(255, 255, 255, math.max(0, math.floor(255 - (255 * float.time))))
        love.graphics.print(float.value, self.posd.x * C_TILE_SIZE + (C_TILE_SIZE / 2)+1, self.posd.y * C_TILE_SIZE - math.floor(C_TILE_SIZE * float.time)+1, 0, 1, 1, math.floor(font:getWidth(float.value) / 2), C_TILE_SIZE + 10)
    end
end


function Player:move(direction)
    moveHandler.move(self, direction)
end


function Player:unmove(direction)
    moveHandler.unmove(self, direction)
end


function Player:addFloatingText(value)
    table.insert(self.floats, 1, { time=0, value=value })
end

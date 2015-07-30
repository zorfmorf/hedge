

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

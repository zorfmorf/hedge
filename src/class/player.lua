

Player = Class{}

function Player:init()
    self. id = 1 -- player always has id 1, only one player allowed at all times
    self.pos = { x=0, y=0 }
    self.dir = nil
end


function Player:place(x, y)
    self.pos = { x=x, y=y }
end


function Player:update(dt)
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

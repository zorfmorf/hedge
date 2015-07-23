
Npc = Class{}

function Npc:init(id)
    self.id = id
    self.pos = { x=0, y=0 }
    self.dir = nil
    self.cycle = 0
    self.anim = 1
end


function Npc:place(x, y)
    self.pos = { x=x, y=y } -- actual current position
    self.tile = { x=x, y=y } -- tile currently occupied
    game.map:addEntity(x, y, self.id)
end


function Npc:update(dt)
    moveHandler.update(self, dt)
    animationHelper.update(self, dt)
end


function Npc:draw()
    animationHelper.draw(self)
end


function Npc:move(direction)
    moveHandler.move(self, direction)
end


function Npc:unmove(direction)
    moveHandler.unmove(self, direction)
end

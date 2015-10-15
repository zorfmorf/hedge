
Npc = Class{}

function Npc:init(id)
    self.id = id
    self.name = "Unnamed"
    self.charset = "default"
    
    -- pos/draw information
    self.pos = { x=0, y=0 } -- actual current position
    self.posd = { x=0, y=0 } -- draw position
    self.dir = "down" -- look direction
    self.walking = false -- if currently walking
    self.anim = 3 -- corresponding animation set
    self.next = nil -- queued movement
    self.cycle = 0 -- anim cycle
end


function Npc:place(x, y, blockMapPlacement)
    self.pos = { x=x, y=y } -- actual current position
    self.posd = { x=x, y=y }
    if not blockMapPlacement then game.map:addEntity(x, y, self.id) end
end


function Npc:update(dt)
    moveHandler.update(self, dt)
    animationHelper.update(self, dt)
end


function Npc:draw()
    animationHelper.draw(self)
end


-- if the player uses a use action on this npc
function Npc:use()
    -- define via npc settings
end


function Npc:move(direction)
    moveHandler.move(self, direction)
end


function Npc:unmove(direction)
    moveHandler.unmove(self, direction)
end

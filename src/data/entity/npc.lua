
Npc = Class{}

function Npc:init(id)
    self.id = id
    self.name = "Unnamed"
    self.charset = "default"
    
    -- pos/draw information
    self.pos = { x=0, y=0 } -- actual current position
    self.posd = { x=0, y=0 } -- draw position
    self.dir = "down" -- look direction
    self.defaultDir = "down"
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


function Npc:doAi()
    if not st_ingame.dialog then
        self.dir = self.defaultDir
    end
end


function Npc:update(dt)
    self:doAi()
    moveHandler.update(self, dt)
    animationHelper.update(self, dt)
end


function Npc:draw()
    animationHelper.draw(self)
end


function Npc:lookAtPlayer()
    if player.pos.x < self.pos.x then self.dir = "left" end
    if player.pos.x > self.pos.x then self.dir = "right" end
    if player.pos.y < self.pos.y then self.dir = "up" end
    if player.pos.y > self.pos.y then self.dir = "down" end
    animationHelper.update(self, 0)
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

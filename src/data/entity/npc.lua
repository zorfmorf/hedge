
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
    self.ai = nil
end


function Npc:place(x, y, blockMapPlacement)
    self.pos = { x=x, y=y } -- actual current position
    self.posd = { x=x, y=y }
    if not blockMapPlacement then game.map:addEntity(x, y, self.id) end
end


function Npc:doAi(dt)
    if not st_ingame.dialog then
        if self.ai == "stroll" then
            if not self.cooldown then self.cooldown = 0 end
            if self.cooldown <= 0 then
                if not self.walking then
                    local dir = math.floor(math.random() * 4)
                    if dir == 0 then self:move("down") self:unmove("down") end
                    if dir == 1 then self:move("left") self:unmove("left") end
                    if dir == 2 then self:move("up") self:unmove("up") end
                    if dir == 3 then self:move("right") self:unmove("right") end
                    self.cooldown = NPC_STROLL_CD
                end
            else
                self.cooldown = self.cooldown - dt
            end
        else
            self.dir = self.defaultDir
        end
    end
end


function Npc:update(dt)
    self:doAi(dt)
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
function Npc:use(x, y)
    -- define via npc settings
end


-- double move npcs so that they don't just turn their head
function Npc:move(direction)
    moveHandler.move(self, direction)
    moveHandler.move(self, direction)
end


function Npc:unmove(direction)
    moveHandler.unmove(self, direction)
end

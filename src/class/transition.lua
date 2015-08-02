
Transition = Class{}

function Transition:init(style, func)
    self.time = 0
    self.style = style
    self.func = func
end


function Transition:update(dt)
    self.time = self.time + dt / C_TRANS_TIME
    if self.time >= 1 and self.func then
        self.func()
        self.func = nil
    end
end


function Transition:isFinished()
    return self.time >= 1 and not self.func
end


function Transition:draw()
    if self.style == "fade_in" then
        love.graphics.setColor(0, 0, 0, math.max(0, 255 - 255 * self.time))
        love.graphics.rectangle("fill", 0, 0, screen.w, screen.h)
    else 
        -- fade out is default
        love.graphics.setColor(0, 0, 0, math.min(255, 255 * self.time))
        love.graphics.rectangle("fill", 0, 0, screen.w, screen.h)
    end
end

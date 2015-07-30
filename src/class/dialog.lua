local font = love.graphics.newFont(20)

Dialog = Class{}

function Dialog:init(id)
    self.id = id
    self.lines = {}
    self.lines[1] =  "This is a dialog line"
    self.lines[2] =  "This is another dialog line"
    self.lines[3] =  "This is the last dialog line"
    self.pos = 1
end


function Dialog:current()
    return self.lines[math.min(self.pos, #self.lines)]
end


function Dialog:advance()
    self.pos = self.pos + 1
end


function Dialog:isFinished()
    return self.pos > #self.lines
end


function Dialog:draw()
    love.graphics.setColor(Color.GREY)
    love.graphics.rectangle("fill", 0, 0, screen.w, screen.h)
    love.graphics.setColor(Color.BLACK)
    love.graphics.rectangle("fill", 0, screen.h - math.floor(screen.h / 4), screen.w, math.floor(screen.h / 4))
    love.graphics.setColor(Color.WHITE)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, screen.h - math.floor(screen.h / 4), screen.w - 1, math.floor(screen.h / 4) - 1)
    love.graphics.setLineWidth(1)
    local tfont = love.graphics.getFont()
    love.graphics.setFont(font)
    love.graphics.printf(self:current(), 20, screen.h - math.floor(screen.h / 4) + 20, screen.w - 22, "left")
    love.graphics.setFont(tfont)
end

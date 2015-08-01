local font = love.graphics.newFont(20)

Dialog = Class{}

function Dialog:init(id)
    self.id = id
    self.lines = {}
    self.lines[1] =  "This is a dialog line"
    self.lines[2] =  "This is another dialog line"
    self.lines[3] =  { { target=4, text="First option, read on", func=function() print("Function call") end }, { target=6, text="Second option, jump to end", func=nil }}
    self.lines[4] =  "This is another dialog line"
    self.lines[5] =  "This is another dialog line"
    self.lines[6] =  "This is the last dialog line"
    self.cursor = 1 -- selected option
    self.pos = 1
end


function Dialog:current()
    return self.lines[math.min(self.pos, #self.lines)]
end


function Dialog:advance()
    local line = self:current()
    if type(line) == "table" then
        self.pos = line[self.cursor].target
        if line[self.cursor].func then line[self.cursor].func() end
    else
        self.pos = self.pos + 1
    end
end


function Dialog:isFinished()
    return self.pos > #self.lines
end


function Dialog:up()
    local line = self:current()
    if type(line) == "table" then
        self.cursor = self.cursor - 1
        if self.cursor < 1 then self.cursor = #line end
    end
end


function Dialog:down()
    local line = self:current()
    if type(line) == "table" then
        self.cursor = self.cursor + 1
        if self.cursor > #line then self.cursor = 1 end
    end
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
    local line = self:current()
    if type(line) == "table" then
        for i,opt in ipairs(line) do
            if self.cursor == i then
                love.graphics.rectangle("fill", 20, screen.h - math.floor(screen.h / 4) + 20 + font:getHeight() * (i - 1), screen.w - 22, font:getHeight())
                love.graphics.setColor(Color.BLACK)
            else
                love.graphics.setColor(Color.WHITE)
            end
            love.graphics.printf(opt.text, 20, screen.h - math.floor(screen.h / 4) + 20 + font:getHeight() * (i - 1), screen.w - 22, "left")
        end
    else
        love.graphics.printf(self:current(), 20, screen.h - math.floor(screen.h / 4) + 20, screen.w - 22, "left")
    end
    love.graphics.setFont(tfont)
end

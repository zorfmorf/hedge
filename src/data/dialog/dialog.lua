local font = love.graphics.newFont(20)

local placeholder = love.graphics.newImage("img/avatar/placeholder.png")

Dialog = Class{}

function Dialog:init(lines)
    self.lines = lines
    self.cursor = 1 -- selected option
    self.pos = 1
end


function Dialog:current()
    return self.lines[math.min(self.pos, #self.lines)]
end


function Dialog:advance()
    local line = self:current()
    if line.options then
        self.pos = line.options[self.cursor].target
        if line.options[self.cursor].func then line.options[self.cursor].func() end
    else
        self.pos = self.pos + 1
    end
end


function Dialog:isFinished()
    return self.pos > #self.lines
end


function Dialog:up()
    local line = self:current()
    if line.options then
        self.cursor = self.cursor - 1
        if self.cursor < 1 then self.cursor = #line.options end
    end
end


function Dialog:down()
    local line = self:current()
    if line.options then
        self.cursor = self.cursor + 1
        if self.cursor > #line.options then self.cursor = 1 end
    end
end


function Dialog:draw()
    
    local line = self:current()
    
    -- fade out game
    love.graphics.setColor(Color.GREY)
    love.graphics.rectangle("fill", 0, 0, screen.w, screen.h)
    
    -- draw avatar
    if line.avatar then
        love.graphics.setColor(Color.WHITE)
        love.graphics.draw(placeholder, screen.w - placeholder:getWidth() - C_DIALOG_LINE_PAD * 2, screen.h, 0, 1, 1, 0, placeholder:getHeight())
    end
    
    -- draw textbox
    love.graphics.setColor(Color.BLACK)
    love.graphics.rectangle("fill", 0, screen.h - math.floor(screen.h / 4), screen.w, math.floor(screen.h / 4))
    love.graphics.setColor(Color.WHITE)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, screen.h - math.floor(screen.h / 4), screen.w - 1, math.floor(screen.h / 4) - 1)
    love.graphics.setLineWidth(1)
    
    -- draw actual text/options
    local tfont = love.graphics.getFont()
    love.graphics.setFont(font)
    local linebuffer = 0
    
    -- name of person speaking
    if line.name then
        love.graphics.setColor(Color.RED)
        love.graphics.printf(line.name, C_DIALOG_PAD, screen.h - math.floor(screen.h / 4) + C_DIALOG_PAD, screen.w - C_DIALOG_PAD * 2 - 2, "left")
        linebuffer = font:getHeight() + C_DIALOG_LINE_PAD
        love.graphics.setColor(Color.WHITE)
    end
    
    -- text
    if line.text then 
        love.graphics.printf(line.text, C_DIALOG_PAD, screen.h - math.floor(screen.h / 4) + C_DIALOG_PAD + linebuffer, screen.w - C_DIALOG_PAD * 2 - 2, "left")
        local w,l = font:getWrap(line.text, screen.w - C_DIALOG_PAD - 2)
        linebuffer = linebuffer + (font:getHeight() + C_DIALOG_LINE_PAD) * l
    end
    
    -- options and option selector
    if line.options then
        for i,opt in ipairs(line.options) do
            if self.cursor == i then
                love.graphics.rectangle("fill", C_DIALOG_PAD, screen.h - math.floor(screen.h / 4) + C_DIALOG_PAD + (font:getHeight() + C_DIALOG_LINE_PAD) * (i - 1) + linebuffer, screen.w - C_DIALOG_PAD * 2 - 2, font:getHeight())
                love.graphics.setColor(Color.BLACK)
            else
                love.graphics.setColor(Color.WHITE)
            end
            love.graphics.printf(opt.text, C_DIALOG_PAD, screen.h - math.floor(screen.h / 4) + C_DIALOG_PAD + (font:getHeight() + C_DIALOG_LINE_PAD) * (i - 1) + linebuffer, screen.w - C_DIALOG_PAD * 2 - 2, "left")
        end
    end
    
    -- restore font
    love.graphics.setFont(tfont)
end

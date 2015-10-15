local font = love.graphics.newFont(20)

local placeholder = love.graphics.newImage("img/avatar/placeholder.png")

Dialog = Class{}

function Dialog:init(lines)
    self.lines = lines
end


function Dialog:ready(id)
    self.pos = 1
    if id then self.pos = id end
    self:prepareCurrentLine()
end


function Dialog:update(dt)
    if not self.box or not (self.box.w == screen.w and self.box.h == screen.h) then
        self.box = { w=screen.w, h=screen.h}
        self.box.img = drawHelper:createGuiBox(screen.w - 4, math.floor(screen.h / 4))
    end 
end


function Dialog:current()
    return self.lines[self.pos]
end


function Dialog:advance()
    
    -- advance to next line (if exists)
    local line = self:current()
    if self.opts then
        local opt = line.options[self.opts[self.cursor]]
        self.pos = opt.target
        if opt.func then opt.func() end
    else
        if line.target then
            self.pos = line.target
        else
            self.pos = self.pos + 1
        end
    end
    
    self.opts = nil
    self:prepareCurrentLine()
end


function Dialog:prepareCurrentLine()
    if not self:isFinished() then
        self.cursor = 1
        local line = self:current()
        if line.options then
            self.opts = {}
            for i,opt in ipairs(line.options) do
                if not opt.cond or opt.cond() then
                    table.insert(self.opts, i)
                end
            end
        else
            self.opts = nil
        end
    end
end


function Dialog:isFinished()
    return self.pos == -1 or self.pos > #self.lines
end


function Dialog:up()
    if self.opts then
        self.cursor = self.cursor - 1
        if self.cursor < 1 then self.cursor = #self.opts end
    end
end


function Dialog:down()
    if self.opts then
        self.cursor = self.cursor + 1
        if self.cursor > #self.opts then self.cursor = 1 end
    end
end


function Dialog:draw()
    
    local line = self:current()
    
    -- fade out game
    love.graphics.setColor(Color.GREY)
    love.graphics.rectangle("fill", 0, 0, screen.w, screen.h)
    
    -- draw avatar
    if line and line.avatar then
        love.graphics.setColor(Color.WHITE)
        love.graphics.draw(placeholder, screen.w - placeholder:getWidth() - C_DIALOG_LINE_PAD * 2, screen.h, 0, 1, 1, 0, placeholder:getHeight())
    end
    
    -- draw textbox
    love.graphics.setColor(Color.WHITE)
    love.graphics.draw(self.box.img, 2, screen.h - math.floor(screen.h / 4))
    
    -- draw actual text/options
    local tfont = love.graphics.getFont()
    love.graphics.setFont(font)
    local linebuffer = 0
    
    -- name of person speaking
    if line and line.name then
        drawHelper:printfColor(Color.BLACK, Color.RED, line.name, C_DIALOG_PAD, screen.h - math.floor(screen.h / 4) + C_DIALOG_PAD, screen.w - C_DIALOG_PAD * 2 - 2, "left")
        linebuffer = linebuffer + font:getHeight()
    end
    
    -- text
    if line and line.text then
        local ltext = line.text()
        
        drawHelper:printf(ltext, C_DIALOG_PAD, screen.h - math.floor(screen.h / 4) + C_DIALOG_PAD + linebuffer, screen.w - C_DIALOG_PAD * 2 - 2, "left")
        
        local w,l = font:getWrap(ltext, screen.w - C_DIALOG_PAD - 2)
        linebuffer = linebuffer + (font:getHeight() + C_DIALOG_LINE_PAD) * l + 10
    end
    
    -- options and option selector
    if line and self.opts then
        for i,opt in ipairs(self.opts) do
            if self.cursor == i then
                love.graphics.rectangle("fill", C_DIALOG_PAD, screen.h - math.floor(screen.h / 4) + C_DIALOG_PAD + (font:getHeight() + C_DIALOG_LINE_PAD) * (i - 1) + linebuffer, screen.w - C_DIALOG_PAD * 2 - 2, font:getHeight())
            end
            love.graphics.setColor(Color.BLACK)
            love.graphics.printf(line.options[opt].text, C_DIALOG_PAD, screen.h - math.floor(screen.h / 4) + C_DIALOG_PAD + (font:getHeight() + C_DIALOG_LINE_PAD) * (i - 1) + linebuffer, screen.w - C_DIALOG_PAD * 2 - 2, "left")
            if not (self.cursor == i) then
                love.graphics.setColor(Color.WHITE)
                love.graphics.printf(line.options[opt].text, C_DIALOG_PAD + 1, screen.h - math.floor(screen.h / 4) + C_DIALOG_PAD + (font:getHeight() + C_DIALOG_LINE_PAD) * (i - 1) + linebuffer + 1, screen.w - C_DIALOG_PAD * 2 - 2, "left")
            end
        end
    end
    
    -- restore font
    love.graphics.setFont(tfont)
end

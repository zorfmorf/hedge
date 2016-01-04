local font = love.graphics.newFont("font/alagard.ttf", 20)

local speech = love.graphics.newImage("img/speech.png")
local thought = love.graphics.newImage("img/thought.png")

local quads = nil

local function createQuads()
    quads = {}
    for i=1,4 do
        quads[i] = {}
        for j=1,3 do
            quads[i][j] = love.graphics.newQuad( (i-1) * C_TILE_SIZE, (j-1) * C_TILE_SIZE, C_TILE_SIZE, C_TILE_SIZE, speech:getWidth(), speech:getHeight() )
        end
    end
    log:msg("verbose", "Created dialog speech quads")
end

Dialog = Class{}

function Dialog:init(lines)
    self.lines = lines
    if not quads then createQuads() end
end


function Dialog:ready(id)
    self.pos = 1
    if id then self.pos = id end
    
    self.timer = 0
    self:prepareCurrentLine()
end


function Dialog:update(dt)
    self.timer = self.timer + dt
end


function Dialog:current()
    return self.lines[self.pos]
end


function Dialog:advance()
    
    if self.timer < C_DIALOG_LINE_TIME then
        self.timer = C_DIALOG_LINE_TIME
    else
    
        -- advance to next line (if exists)
        local line = self:current()
        if self.opts then
            local opt = line.options[self.opts[self.cursor]]
            self.pos = opt.target
            if opt.func then opt.func() end
        else
            if line.func then line.func() end
            if line.target then
                self.pos = line.target
            else
                self.pos = self.pos + 1
            end
        end
        
        self.opts = nil
        self:prepareCurrentLine()
        
    end
end


function Dialog:prepareCurrentLine()
    
    -- Advance lines until current line has no condition or a condition that is fulfilled
    local line = self:current()
    while line and line.cond and not line.cond() do
        self.pos = self.pos + 1
        line = self:current()
    end
    
    if not self:isFinished() then
        self.timer = 0
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
        self.cursor = math.max(1, self.cursor - 1)
    end
end


function Dialog:down()
    if self.opts then
        self.cursor = math.min(self.cursor + 1, #self.opts)
    end
end


local function drawBubble(dox, doy, width, height, sx, sy, think)
    local img = speech
    if think then img = thought end
    love.graphics.setColor(Color.WHITE)
    love.graphics.rectangle("fill", dox, doy, width, height )
    
    love.graphics.draw(img, quads[1][1], dox - C_TILE_SIZE, doy - C_TILE_SIZE)
    love.graphics.draw(img, quads[4][1], dox + width, doy - C_TILE_SIZE)
    love.graphics.draw(img, quads[1][3], dox - C_TILE_SIZE, doy + height)
    love.graphics.draw(img, quads[4][3], dox + width, doy + height)
    local buffer = 0
    while buffer < width do
        love.graphics.draw(img, quads[3][1], dox + buffer, doy - C_TILE_SIZE)
        love.graphics.draw(img, quads[3][3], dox + buffer, doy + height)
        buffer = buffer + C_TILE_SIZE
    end
    buffer = 0
    while buffer < height do
        love.graphics.draw(img, quads[1][2], dox - C_TILE_SIZE, doy + buffer)
        love.graphics.draw(img, quads[4][2], dox + width, doy + buffer)
        buffer = buffer + C_TILE_SIZE
    end
    if doy < sy then 
        love.graphics.draw(img, quads[2][3], sx, sy - C_TILE_SIZE * 2)
    else
        love.graphics.draw(img, quads[2][1], sx, sy + C_TILE_SIZE)
    end
end


function Dialog:draw()
    
    local line = self:current()
    
    if self.x and self.y and line then
        
        love.graphics.setFont(font)
        
        local text = nil
        if line.text then text = line.text() end
        
        if text then
            
            if self.timer > C_DIALOG_LINE_TIME and math.floor(self.timer * C_DIALOG_LINE_BLINK) % 2 == 0 then 
                text = text .. " ▼"
            else
                text = text .. "  "
            end
            
            local width = 320
            local lwidth, lines = font:getWrap(text, width)
            lines = math.max(2, #lines)
            if line.name then lines = lines + 1 end
            local height = math.floor(0.9 * lines * font:getHeight())
            local rest = height % C_TILE_SIZE
            if rest > 0 then height = height + (C_TILE_SIZE - rest) end
            local sx, sy = drawHelper:screenCoords(self.x, self.y)
            
            if line.player then
                sx, sy = drawHelper:screenCoords(player.pos.x, player.pos.y)
            end
            
            local dox = sx - width * 0.5
            local doy = sy - height - C_TILE_SIZE * 2
            
            drawBubble(dox, doy, width, height, sx, sy, line.think)
            
            local namebuffer = 0
            
            if line.name then
                local v = player.name
                if type(line.name) == "string" then v = line.name end
                love.graphics.setColor(Color.RED_HARD)
                love.graphics.print(v, dox, doy)
                namebuffer = namebuffer + font:getHeight()
            end
            
            love.graphics.setColor(Color.BLACK)
            local percentage = math.min(self.timer, C_DIALOG_LINE_TIME) / C_DIALOG_LINE_TIME
            local charAmount = math.floor(text:len() * percentage)
            love.graphics.printf(text:sub(1, charAmount), dox, doy + namebuffer, width)
        else
            self.timer = C_DIALOG_LINE_TIME + 0.01
        end
        
        if self.opts and self.timer > C_DIALOG_LINE_TIME then
            
            local width = 0
            for i,opt in ipairs(self.opts) do
                width = math.max(width, font:getWidth(line.options[opt].text))
            end
            local rest = width % C_TILE_SIZE
            if rest > 0 then width = width + (C_TILE_SIZE - rest) end
            local height = font:getHeight() * (#self.opts - 1)
            rest = height % C_TILE_SIZE
            if rest > 0 then height = height + (C_TILE_SIZE - rest) end
            local sx, sy = drawHelper:screenCoords(player.pos.x, player.pos.y)
            local dox = sx - width * 0.5
            local doy = sy + C_TILE_SIZE * 2
            
            drawBubble(dox, doy, width, height, sx, sy)
            
            for i,opt in ipairs(self.opts) do
                love.graphics.setColor(Color.GREY)
                local text = "  " .. line.options[opt].text
                if self.cursor == i then
                    love.graphics.setColor(Color.BLACK)
                    love.graphics.rectangle("fill", dox, doy + (i - 1) * font:getHeight() + math.floor(font:getHeight() * 0.4), 8, 8)
                end
                love.graphics.print(text, dox, doy + (i - 1) * font:getHeight())
            end
        end
    end
end

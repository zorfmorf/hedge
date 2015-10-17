local font = love.graphics.newFont("font/alagard.ttf", 20)

local speech = love.graphics.newImage("img/speech.png")

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
    self:prepareCurrentLine()
end


function Dialog:update(dt)
    
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
    
    if self.x and self.y and line.text then
        
        love.graphics.setFont(font)
        
        local text = line.text()
        
        local width = 320
        local lwidth, lines = font:getWrap(text, width)
        local height = lines * font:getHeight()
        local rest = height % C_TILE_SIZE
        height = height + (C_TILE_SIZE - rest)
        local sx, sy = drawHelper:screenCoords(self.x, self.y)
        
        local dox = sx - width * 0.5
        local doy = sy - height - C_TILE_SIZE * 3
        
        love.graphics.setColor(Color.WHITE)
        love.graphics.rectangle("fill", dox, doy, width, height )
        
        love.graphics.draw(speech, quads[1][1], dox - C_TILE_SIZE, doy - C_TILE_SIZE)
        love.graphics.draw(speech, quads[4][1], dox + width, doy - C_TILE_SIZE)
        love.graphics.draw(speech, quads[1][3], dox - C_TILE_SIZE, doy + height)
        love.graphics.draw(speech, quads[4][3], dox + width, doy + height)
        local buffer = 0
        while buffer < width do
            love.graphics.draw(speech, quads[2][1], dox + buffer, doy - C_TILE_SIZE)
            love.graphics.draw(speech, quads[3][3], dox + buffer, doy + height)
            buffer = buffer + C_TILE_SIZE
        end
        buffer = 0
        while buffer < lines do
            love.graphics.draw(speech, quads[1][2], dox - C_TILE_SIZE, doy + buffer * C_TILE_SIZE)
            love.graphics.draw(speech, quads[4][2], dox + width, doy + buffer * C_TILE_SIZE)
            buffer = buffer + 1
        end
        love.graphics.draw(speech, quads[2][3], sx, sy - C_TILE_SIZE * 3)
        
        love.graphics.setColor(Color.BLACK)
        love.graphics.printf(text, dox, doy, width)
        
    end
end

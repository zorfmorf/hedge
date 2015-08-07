--[[-- 
    
    A brush is used for drawing maps in the editor
    
--]]--

Brush = Class{}


function Brush:init(id)
    
    self.name = "Brush " .. id
    
    -- if a player can walk on the tile after this brush has been used on it
    self.blocking = false
    
    -- the following sets can be empty (nothing drawn), have one item or multiple (random one)
    
    -- the floor tile(s) applied by this brush
    self.tiles = nil
    
    -- the object tiles applied by this are drawn over floor (but under player)
    self.objects = nil
    
    -- overlays are drawn over the player
    self.overlays = nil
    
    -- event placed by this brush
    self.event = nil
    
end


function Brush:addTile(at, tx, ty)
    if not self.tiles then self.tiles = {} end
    table.insert(self.tiles, {at, tx, ty})
end


function Brush:addObject(at, tx, ty)
    if not self.objects then self.objects = {} end
    table.insert(self.objects, {at, tx, ty})
end


function Brush:addOverlay(at, tx, ty)
    if not self.overlays then self.overlays = {} end
    table.insert(self.overlays, {at, tx, ty})
end


function Brush:getTile()
    if self.tiles then
        return self.tiles[math.random(1, #self.tiles)]
    end
    return nil
end


function Brush:getObject()
    if self.objects then
        return self.objects[math.random(1, #self.objects)]
    end
    return nil
end


function Brush:getOverlay()
    if self.overlays then
        return self.overlays[math.random(1, #self.overlays)]
    end
    return nil
end


-- preview the brash by drawing the first tile that can be found
-- x,y coordinates to draw to and the default to use if not found
function Brush:drawPreview(x, y, default)
    local t = nil
    if self.tiles and self.tiles[1] then t = self.tiles end
    if not t and self.objects and self.objects[1] then t = self.objects end
    if not t and self.overlays and self.overlays[1] then t = self.overlays end
    
    if t and t[1] then
        local atl = game.atlanti[t[1][1]]
        local quad = love.graphics.newQuad( t[1][2] * C_TILE_SIZE, t[1][3] * C_TILE_SIZE, C_TILE_SIZE, C_TILE_SIZE, atl.img:getWidth(), atl.img:getHeight() )
        love.graphics.draw(atl.img, quad, x, y)
    elseif default then
        love.graphics.draw(default, x, y)
    end
end


local function lineFromLayer(layer)
    local line = "nil"
    if layer then
        line = ""
        local first = true
        for i,set in ipairs(layer) do
            for j,value in ipairs(set) do
                if first then first = false else line = line .. "," end
                line = line .. value
            end
        end
    end
    return line
end


local function layerFromLine(line)
    local result = {}
    local current = {}
    for i,entry in ipairs(line:split(",")) do
        table.insert(current, tonumber(entry))
        if i % 3 == 0 then
            table.insert(result, current)
            current = {}
        end
    end
    return result
end


-- create a line representation of the brush
function Brush:toLine()
    local line = self.name:gsub('%W','')..";" --strip special chars from name
    line = line .. tostring(self.blocking)..";"
    line = line .. lineFromLayer(self.tiles)..";"
    line = line .. lineFromLayer(self.objects)..";"
    line = line .. lineFromLayer(self.overlays)..";"
    line = line .. tostring(self.event)
    return line
end


-- read brush settings from a line representation
function Brush:fromLine(line)
    for i,entry in ipairs(line:split(";")) do
        if i == 1 then self.name = entry end
        if i == 2 then 
            self.blocking = false
            if entry == "true" then self.blocking = true end
        end
        if i == 3 then self.tiles = layerFromLine(entry) end
        if i == 4 then self.objects = layerFromLine(entry) end
        if i == 5 then self.overlays = layerFromLine(entry) end
        if i == 6 and not entry == "nil" then self.event = tonumber(entry) end
    end
end

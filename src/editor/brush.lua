--[[-- 
    
    A brush is used for drawing maps in the editor
    
--]]--

Brush = Class{}


function Brush:init(id)
    
    self.name = "Brush" .. id
    
    -- if a player can walk on the tile after this brush has been used on it
    self.blocking = true
    
    -- the following sets can be empty (nothing drawn), have one item or multiple (random one)
    
    -- the floor tile(s) applied by this brush
    self.tiles = nil
    
    -- the floor2 tile(s) applied by this brush
    self.tiles2 = nil
    
    -- the object tiles applied by this are drawn over floor (but under player)
    self.objects = nil
    
    -- border tiles for intelligent brush
    self.border = nil
    
    -- overlays are drawn over the player
    self.overlays = nil
    
    -- event placed by this brush
    self.event = nil
    
end


function Brush:addTile(at, tx, ty)
    if not self.tiles then self.tiles = {} end
    table.insert(self.tiles, {at, tx, ty})
end


function Brush:addTile2(at, tx, ty)
    if not self.tiles2 then self.tiles2 = {} end
    table.insert(self.tiles2, {at, tx, ty})
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


function Brush:getTile2()
    if self.tiles2 then
        return self.tiles2[math.random(1, #self.tiles2)]
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


function Brush:addBorder()
    self.border = {}
    self.border.inner = {}
    self.border.outer = {}
    self.border.side = {}
end


-- preview the brash by drawing the first tile that can be found
-- x,y coordinates to draw to and the default to use if not found
function Brush:drawPreview(x, y, default)
    local t = nil
    if self.tiles and self.tiles[1] then t = self.tiles end
    if not t and self.tiles2 and self.tiles2[1] then t = self.tiles2 end
    if not t and self.objects and self.objects[1] then t = self.objects end
    if not t and self.overlays and self.overlays[1] then t = self.overlays end
    
    if t and t[1] then
        local atl = brushHandler.getAtlanti()[t[1][1]]
        local quad = love.graphics.newQuad( t[1][2] * C_TILE_SIZE, t[1][3] * C_TILE_SIZE, C_TILE_SIZE, C_TILE_SIZE, atl.img:getWidth(), atl.img:getHeight() )
        love.graphics.draw(atl.img, quad, x, y)
    elseif default then
        love.graphics.draw(default, x, y)
    end
end


local function brushEqTile(brushtiles, tile)
    for i,texture in pairs(brushtiles) do
        if texture[1] == tile[1] and texture[2] == tile[2] and texture[3] == tile[3] then
            return true
        end
    end
    return false
end


-- return true if the given tile has textures from this brush
function Brush:onTile(tx, ty)
    local tile = game.map:getTile(tx, ty)
    if tile then 
        if self.tiles and tile.floor then 
            if brushEqTile(self.tiles, tile.floor) then return true end
        end
        if self.tiles2 and tile.floor2 then 
            if brushEqTile(self.tiles2, tile.floor2) then return true end
        end
        if self.objects and tile.object then 
            if brushEqTile(self.objects, tile.object) then return true end
        end
        if self.overlays and tile.overlay then 
            if brushEqTile(self.overlays, tile.overlay) then return true end
        end
    end
    return false
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


local function strFromBorderpart(part)
    local str = "-1,-1,-1"
    if part then
        str = part[1]..","..part[2]..","..part[3]
    end
    return str
end


local function lineFromBorder(border)
    local line = "nil"
    if border then
        line = strFromBorderpart(border.inner.ul)..","
        line = line .. strFromBorderpart(border.inner.ur)..","
        line = line .. strFromBorderpart(border.inner.ll)..","
        line = line .. strFromBorderpart(border.inner.lr)..","
        line = line .. strFromBorderpart(border.outer.ul)..","
        line = line .. strFromBorderpart(border.outer.ur)..","
        line = line .. strFromBorderpart(border.outer.ll)..","
        line = line .. strFromBorderpart(border.outer.lr)..","
        line = line .. strFromBorderpart(border.side.u)..","
        line = line .. strFromBorderpart(border.side.l)..","
        line = line .. strFromBorderpart(border.side.r)..","
        line = line .. strFromBorderpart(border.side.d)
    end
    return line
end


local function borderFromLine(line)
    local border = nil
    if not (line == "nil") then
        border = {}
        border.inner = {}
        border.outer = {}
        border.side = {}
        local v = line:split(',')
        local i = 1
        
        -- inner
        if not (tonumber(v[i]) == -1) then
            border.inner.ul = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        if not (tonumber(v[i]) == -1) then
            border.inner.ur = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        if not (tonumber(v[i]) == -1) then
            border.inner.ll = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        if not (tonumber(v[i]) == -1) then
            border.inner.lr = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        
        -- outer
        if not (tonumber(v[i]) == -1) then
            border.outer.ul = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        if not (tonumber(v[i]) == -1) then
            border.outer.ur = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        if not (tonumber(v[i]) == -1) then
            border.outer.ll = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        if not (tonumber(v[i]) == -1) then
            border.outer.lr = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        
        -- outer
        if not (tonumber(v[i]) == -1) then
            border.side.u = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        if not (tonumber(v[i]) == -1) then
            border.side.l = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        if not (tonumber(v[i]) == -1) then
            border.side.r = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
        i = i + 3
        if not (tonumber(v[i]) == -1) then
            border.side.d = {tonumber(v[i]), tonumber(v[i+1]), tonumber(v[i+2])}
        end
    end
    return border
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
    local line = tostring(self.id)..";"
    line = line .. self.name:gsub('%W','')..";" --strip special chars from name
    if self.tile then
        line = line .. "obrush;"..self.xsize..";"..self.ysize..";"
        local isFirst = true
        for x,row in pairs(self.tile) do
            for y,tile in pairs(row) do
                if isFirst then isFirst = false else line = line .. "," end
                line = line..tile[1]..","..tile[2]..","..tile[3]..","
                if tile.overlay then
                    line = line.."true"
                else
                    line = line.."false"
                end
            end
        end
    else
        line = line .. tostring(self.blocking)..";"
        line = line .. lineFromLayer(self.tiles)..";"
        line = line .. lineFromLayer(self.tiles2)..";"
        line = line .. lineFromLayer(self.objects)..";"
        line = line .. lineFromLayer(self.overlays)..";"
        line = line .. lineFromBorder(self.border)
    end
    return line
end


-- read brush settings from a line representation
function Brush:fromLine(line)
    local v = line:split(";")
    
    if v[3] == "obrush" then
        Class.include(self, OBrush)
        self.id = tonumber(v[1])
        self.name = v[2]
        self.xsize = tonumber(v[4])
        self.ysize = tonumber(v[5])
        self.tile = {}
        self.isObjectBrush = function() return true end
        local x = 1
        local y = 1
        local en = v[6]:split(',')
        for i=1,#en,4 do
            self:set(x, y, { tonumber(en[i]), tonumber(en[i+1]), tonumber(en[i+2]), tonumber(en[i+3]) })
            x = x + 1
            if x > self.xsize then
                x = 1
                y = y + 1
            end
        end
    else
        for i,entry in ipairs(v) do
            if i == 1 then self.id = tonumber(entry) end
            if i == 2 then self.name = entry end
            if i == 3 then 
                self.blocking = false
                if entry == "true" then self.blocking = true end
            end
            if i == 4 then self.tiles = layerFromLine(entry) end
            if i == 5 then self.tiles2 = layerFromLine(entry) end
            if i == 6 then self.objects = layerFromLine(entry) end
            if i == 7 then self.overlays = layerFromLine(entry) end
            if i == 8 then self.border = borderFromLine(entry) end
        end
    end
end


function Brush:isObjectBrush()
    return false
end

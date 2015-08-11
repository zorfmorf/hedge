
OBrush = Class{__includes = Brush}


function OBrush:init(id)
    
    self.name = "Brush" .. id
    
    self.xsize = 1
    self.ysize = 1
    
    -- object layer
    self.tile = {}
    self.tile[1] = {}
    self.tile[1][1] = nil
end


function OBrush:set(x, y, tile)
    if not self.tile[x] then self.tile[x] = {} end
    self.tile[x][y] = tile
end


function OBrush:get(x, y)
    if self.tile[x] then
        return self.tile[x][y]
    end
    return nil
end


function OBrush:isObjectBrush()
    return true
end
--[[-- 
    
    A brush is used for drawing maps in the editor
    
--]]--

Brush = Class{}


function Brush:init(id)
    
    self.name = "Brush #" .. id
    
    -- if a player can walk on the tile after this brush has been used on it
    self.blocking = false
    
    -- the following sets can be empty (nothing drawn), have one item or multiple (random one)
    
    -- the floor tile(s) applied by this brush
    self.tiles = nil
    
    -- the object tiles applied by this are drawn over floor (but under player)
    self.objects = nil
    
    -- overlays are drawn over the player
    self.overlays = nil
    
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

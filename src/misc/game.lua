--[[--
--
-- Container for all game components
--
--]]--

game = {}

function game:init()
    
    self.map = maploader:read()
    self.atlanti = tilesetreader:read()
    self.brushes = {}
    
    --map:setTile(0, 0, sTile[1], sTile[2], sTile[3])
    table.insert(self.brushes, Brush(1))
    self.brush = 1
    self.brushes[1].tiles = { {1, 21, 5}, {1, 22, 5}, {1, 23, 5} }
end

function game:getCurrentBrush()
    return self.brushes[self.brush]
end

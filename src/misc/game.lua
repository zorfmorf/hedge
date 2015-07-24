--[[--
--
-- Container for all game components
--
--]]--

game = {}

function game:init(editmode)
    
    -- todo: account for different savegamefolders
    local path = C_MAP_CURRENT
    if editmode then path = C_MAP_MASTER end
    
    self.map = maploader:read(path, C_MAP_NAME_DEFAULT)
    self.atlanti = tilesetreader:read()
    self.brushes = {}
    
    -- add one default brush
    table.insert(self.brushes, Brush(1))
    self.brush = 1
    self.brushes[1].tiles = { {1, 21, 5}, {1, 22, 5}, {1, 23, 5} }
end


function game:getCurrentBrush()
    return self.brushes[self.brush]
end

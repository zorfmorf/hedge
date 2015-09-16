--[[--
--
-- Container for all game components
--
--]]--

game = {}

function game:init(editmode)
    
    log:msg("verbose", "Initiating game container")
    
    self.editmode = editmode
    
    local path = C_MAP_CURRENT
    
    if editmode then
        path = C_MAP_MASTER 
    else
        self.atlas = TexAtlas(C_MAP_CURRENT..C_MAP_GAME_ATLAS )
        self.mapping = tilesetPacker.read( C_MAP_CURRENT..C_MAP_GAME_ATLAS_MAPPING )
    end
    
    if var.get("current_map") then
        self.map = maploader:read(path, var.get("current_map")..C_MAP_SUFFIX)
    else
        self.map = maploader:read(path, C_MAP_NAME_DEFAULT)
    end
    
    if not self.plants then self.plants = {} end
    self:updatePlants()
    
end


function game:updatePlants(value)
    
    -- update state & visuals for non-wheat plants
    for i,plant in ipairs(self.plants) do
        plant:update(value)
    end
    
    -- update visuals for wheat plants
    for i,plant in ipairs(self.plants) do
        if plant.type == "Wheat" then
            plant:updateVisuals()
        end
    end
end

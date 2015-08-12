--[[--
--
-- Container for all game components
--
--]]--

game = {}

function game:init(editmode)
    
    local path = C_MAP_CURRENT
    if editmode then path = C_MAP_MASTER end
    if var.get("current_map") then
        self.map = maploader:read(path, var.get("current_map")..C_MAP_SUFFIX)
    else
        self.map = maploader:read(path, C_MAP_NAME_DEFAULT)
    end
    
    if not brushHandler.getAtlanti() then brushHandler.init() end
    
end


local lines = {}

local function tired()
    st_ingame.transition = Transition("fade_out", function()
            maploader:save(game.map, C_MAP_CURRENT)
            game.map = maploader:read(C_MAP_CURRENT, C_MAP_NAME_DEFAULT)
            st_ingame:placePlayer(3, 0)
            timeHandler.oversleep()
        end)
end

lines[1] = { text = function() return "*Yawn*" end }
lines[2] = { text = function() return "I really need to go to bed now ..." end, func = function() tired() end }

return lines

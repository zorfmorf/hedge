
local function createStore()
    local container = Container("seed_store", { buy=true })
    container:add(itemCreator:getCucumberSeeds(99))
    container:add(itemCreator:getCarrotSeeds(99))
    container:add(itemCreator:getCabbageSeeds(99))
    container:add(itemCreator:getCorn(99))
    container:add(itemCreator:getPotatoe(99))
    container:add(itemCreator:getSeedbag())
    st_ingame.container = container
    container:update(0)
end

local lines = {}

lines[1] = { name = "Market woman", text = function() return "I have never seen you before. Are you new in town?" end, target=-1 }
return lines


local function createStore()
    local container = Container(id, { buy=true })
    container:add(itemCreator:getCucumberSeeds(99))
    container:add(itemCreator:getCarrotSeeds(99))
    container:add(itemCreator:getCabbageSeeds(99))
    container:add(itemCreator:getCorn(99))
    container:add(itemCreator:getPotatoe(99))
    st_ingame.container = container
    container:update(0)
end

local lines = {}

lines[1] = { name = "Karen", text = function() return "Welcome to Seedy's. How can I help you?" end }
lines[2] = { text = function() return "" end, 
                    options={ 
                        { target=4, text="I'd like to buy some seeds", func=function() createStore() end }, 
                        { target=3, text="Nothing at the moment, I'm just browsing"}
                    }
                }
lines[3] = { name = "Karen", text = function() return "Sure, take your time!" end }
return lines

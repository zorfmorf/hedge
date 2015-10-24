
local function createStore()
    local container = Container("karen_store", { buy=true })
    container:add(itemCreator:getCucumberSeeds(99))
    container:add(itemCreator:getCarrotSeeds(99))
    container:add(itemCreator:getCabbageSeeds(99))
    container:add(itemCreator:getCorn(99))
    container:add(itemCreator:getPotatoe(99))
    st_ingame.container = container
    container:update(0)
end

local lines = {}

lines[1] = { name = "Karen", text = function() return "Please don't come behind the counter..." end, target=-1 }
lines[2] = { name = "Karen", text = function() return "Could you NOT? That's my bedroom up there!" end, target=-1 }
lines[3] = { name = "Karen", text = function() return "Welcome to my store. I sell seeds ... yeah that's about it." end }
lines[4] = { name = "Karen", text = function() return "How can I help you?" end, 
                    options={ 
                        { target=-1, text="I'd like to buy some seeds", func=function() createStore() end }, 
                        { target=5, text="Nothing at the moment, I'm just browsing"}
                    }
                }
lines[5] = { name = "Karen", text = function() return "Sure, take your time!" end }
lines[6] = { name = "Karen", text = function() return "Ugh, another window shopper ..." end, think=true }
return lines


local container = nil

local function sellItems()
    if not container then container = Container("pawn_store", { buy=true }) end
    st_ingame.container = container
    inventory.flags = {}
    inventory.flags.sell = true
    inventory.target = container
    inventory:reset()
    st_ingame.container = inventory
    inventory:update(0)
end

local function buyItems()
    if not container then container = Container("pawn_store", { buy=true }) end
    st_ingame.container = container
    container:update(0)
end

local lines = {}

lines[1] = { name = "Lew Greenbuck", text = function() return "Welcome to Lew Greenbuck's Pawn Store!" end,
                options={ 
                    { target=-1, text="I have some things to sell", func=function() sellItems() end },
                    { target=-1, text="I'm looking for something", func=function() buyItems() end },
                    { target=-1, text="Nothing at the moment, I'm just browsing"}
                }
            }

return lines

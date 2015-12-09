
local name = "Lew Greenbuck"
local unknown = "Man"
local varname = "lew_met"

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

lines[1] = { name = name, text = function() return "How can I help you?" end, cond = function() return var.get(varname) end,
                options={ 
                    { target=-1, text="I have some things to sell", func=function() sellItems() end },
                    { target=-1, text="I'm looking for something", func=function() buyItems() end },
                    { target=-1, text="Nothing at the moment, I'm just browsing"}
                }
            }
lines[2] = { name = unknown, text = function() return "Welcome to Lew Greenbuck's Pawn Store! You must be "..player.name.."?" end }
lines[3] = { name = true, player = true, text = function() return "Yes, how do you know?" end }
lines[4] = { name = unknown, text = function() return "Oh, word just has a way of getting around town here really fast." end }
lines[5] = { name = unknown, text = function() return "Anyway - I'm "..name.." and I trade in ... everything." end }
lines[6] = { name = true, player = true, text = function() return "Anything? How does that work?" end }
lines[7] = { name = unknown, text = function() return "If you have anything to sell, I'm gonna buy it ... unless it's tools." end }
lines[8] = { name = unknown, text = function() return "Oh and another tip: If you have produce to sell, might want to think about selling it yourself." end }
lines[9] = { name = unknown, text = function() return "You can use the stall to my left. It's free to use and you earn more money this way, though it will take some time." end }
lines[10] = { name = true, player = true, text = function() return "Thanks, got it!" end, target=1, func = function() var.set(varname, 1) end }

return lines

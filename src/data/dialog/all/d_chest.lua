
local function loadChest()
    if not chest then
        chest = Container("chest", {}, 9999999)
        chest:load()
    end
end

local function storeItems()
    loadChest()
    inventory.flags = {}
    inventory.flags.store = true
    inventory.target = chest
    st_ingame.container = inventory
end

local function retrieveItems()
    loadChest()
    chest.flags = {}
    chest.flags.retrieve = true
    chest.target = inventory
    st_ingame.container = chest
    chest:update(0)
end

local lines = {}

lines[1] = { text = function() return nil end, 
                    options={ 
                        { target=-1, text="Store items", func=function() storeItems() end }, 
                        { target=-1, text="Retrieve items", func=function() retrieveItems() end}
                    }
                }
return lines

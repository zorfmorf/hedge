
local function createStore()
    local container = Container("tool_store", { buy=true })
    local item = inventory:hasItem("Axe")
    if item and item.level < 3 then
        container:add(itemCreator:getAxe(item.level + 1))
    else
        container:add(itemCreator:getAxe(1))
    end
    item = inventory:hasItem("Spade")
    if item and item.level < 3 then
        container:add(itemCreator:getShovel(item.level + 1))
    else
        container:add(itemCreator:getShovel(1))
    end
    item = inventory:hasItem("Pickaxe")
    if item and item.level < 3 then
        container:add(itemCreator:getPickaxe(item.level + 1))
    else
        container:add(itemCreator:getPickaxe(1))
    end
    item = inventory:hasItem("Scythe")
    if item and item.level < 3 then
        container:add(itemCreator:getScythe(item.level + 1))
    else
        container:add(itemCreator:getScythe(1))
    end
    st_ingame.container = container
    container:update(0)
end

local lines = {}

lines[1] = { name = "Tim", text = function() return "Hey now, this is where I'm supposed to *hick* stand." end, target=-1 }
lines[2] = { name = "Tim", text = function() return "What ya want?" end,
                options={ 
                    { target=-1, text="I'd like to buy some tools", func=function() createStore() end }, 
                    { target=-1, text="Nothing at the moment, I'm just browsing"}
                }
            }

return lines

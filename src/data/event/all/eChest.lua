-- a big stone on the field

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    inventory:add(itemCreator:getAxe(0))
    inventory:add(itemCreator:getShovel(0))
    inventory:add(itemCreator:getPickaxe(0))
    inventory:add(itemCreator:getScythe(0))
    inventory:add(itemCreator:getSeedbag())
    inventory:add(itemCreator:getPotatoe(2))
end


return {
        id = 2,
        init = init,
        use = use,
        walk = walk
    }
-- a big stone on the field

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    inventory:add(Tool("Axe", 0))
    inventory:add(Tool("Shovel", 0))
    inventory:add(Tool("Pickaxe", 1))
    inventory:add(Tool("Scythe", 2))
    inventory:add(Seedbag())
    inventory:add(itemCreator:getPotatoe(2))
end


return {
        id = 2,
        init = init,
        use = use,
        walk = walk
    }
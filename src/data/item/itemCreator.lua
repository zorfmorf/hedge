
itemCreator = {}


function itemCreator:getAxe(level)
    return Tool("Axe", level, 10 + 100 * level)
end


function itemCreator:getShovel(level)
    return Tool("Shovel", level, 10 + 100 * level)
end


function itemCreator:getPickaxe(level)
    return Tool("Pickaxe", level, 10 + 100 * level)
end


function itemCreator:getScythe(level)
    return Tool("Scythe", level, 10 + 100 * level)
end


function itemCreator:getSeedbag()
    return Seedbag()
end


function itemCreator:getPotatoe(amount)
    return Item("Potatoes", amount, { produce=true, food=true, seed=true, sellable=true}, 5)
end

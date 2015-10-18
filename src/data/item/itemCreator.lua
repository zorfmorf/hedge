
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


function itemCreator:getCucumber(amount)
    return Item("Cucumber", amount, { produce=true, food=true, seed=false, sellable=true}, 5)
end


function itemCreator:getCucumberSeeds(amount)
    return Item("Cucumber seeds", amount, { produce=false, food=false, seed=true, sellable=true}, 5)
end


function itemCreator:getCarrot(amount)
    return Item("Carrot", amount, { produce=true, food=true, seed=false, sellable=true}, 5)
end


function itemCreator:getCarrotSeeds(amount)
    return Item("Carrot seeds", amount, { produce=false, food=false, seed=true, sellable=true}, 5, "A small ruebe sorte. It is said that eating carrotts grants good eye sight.")
end


function itemCreator:getCabbage(amount)
    return Item("Cabbage", amount, { produce=true, food=true, seed=false, sellable=true}, 5)
end


function itemCreator:getCabbageSeeds(amount)
    return Item("Cabbage seeds", amount, { produce=false, food=false, seed=true, sellable=true}, 5)
end


function itemCreator:getWheat(amount)
    return Item("Wheat", amount, { produce=true, food=false, seed=false, sellable=true}, 5)
end


function itemCreator:getCorn(amount)
    return Item("Corn", amount, { produce=true, food=false, seed=true, sellable=true}, 2)
end


function itemCreator:getStone(amount)
    return Item("Stone", amount, { produce=false, food=false, seed=false, sellable=true}, 20)
end

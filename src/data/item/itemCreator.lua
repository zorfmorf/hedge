
itemCreator = {}


local text = {}
text.carrot = "Root vegetable that is used in many dishes and therefore high in demand."
text.cucumberplant = "Ground vine plant that bears multiple fruits."
text.cucumber = "Can be eaten fresh or pickled to make it last deep into winter."
text.potatoe = "Cheap and simple to grow, yet time-consuming to harvest."
text.cabbage = "Used fresh as condiment or salad. Fermented or pickled to make it last deep into winter."
text.cabbageplant = "A large plant whose big head can be harvested."
text.wheat = "Can be threshed to seperate the corn from chaff."
text.corn = "Can be either planted to grow wheat or ground into flour with a mill."
text.stone = "Used as a building material. Really heavy."
text.wood = "Basic building material that also keeps you warm in the winter."


function itemCreator:getAxe(level)
    return Tool("Axe", level, 10^level)
end


function itemCreator:getShovel(level)
    return Tool("Shovel", level, 10^level)
end


function itemCreator:getPickaxe(level)
    return Tool("Pickaxe", level, 10^level)
end


function itemCreator:getScythe(level)
    return Tool("Scythe", level, 10^level)
end


function itemCreator:getSeedbag()
    return Seedbag()
end


function itemCreator:getPotatoe(amount)
    return Item("Potatoes", amount, { produce=true, food=true, seed=true, sellable=true}, 2, text.potatoe)
end


function itemCreator:getCucumber(amount)
    return Item("Cucumber", amount, { produce=true, food=true, seed=false, sellable=true}, 10, text.cucumber)
end


function itemCreator:getCucumberSeeds(amount)
    return Item("Cucumber seeds", amount, { produce=false, food=false, seed=true, sellable=true}, 10, text.cucumberplant)
end


function itemCreator:getCarrot(amount)
    return Item("Carrot", amount, { produce=true, food=true, seed=false, sellable=true}, 40, text.carrot)
end


function itemCreator:getCarrotSeeds(amount)
    return Item("Carrot seeds", amount, { produce=false, food=false, seed=true, sellable=true}, 20, text.carrot)
end


function itemCreator:getCabbage(amount)
    return Item("Cabbage", amount, { produce=true, food=true, seed=false, sellable=true}, 30, text.cabbage)
end


function itemCreator:getCabbageSeeds(amount)
    return Item("Cabbage seeds", amount, { produce=false, food=false, seed=true, sellable=true}, 15, text.cabbageplant)
end


function itemCreator:getWheat(amount)
    return Item("Wheat", amount, { produce=true, food=false, seed=false, sellable=true}, 8, text.wheat)
end


function itemCreator:getCorn(amount)
    return Item("Corn", amount, { produce=true, food=false, seed=true, sellable=true}, 4, text.corn)
end


function itemCreator:getStone(amount)
    return Item("Stone", amount, { produce=false, food=false, seed=false, sellable=true}, 20, text.stone)
end


function itemCreator:getWood(amount)
    return Item("Wood", amount, { produce=false, food=false, seed=false, sellable=true}, 10, text.wood)
end

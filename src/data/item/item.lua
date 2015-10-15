
Item = Class{}


function Item:init(id, count, flags, price)
    self.flags = {}
    if flags then self.flags = flags end
    self.id = id
    self.price = 1 -- price in gold
    if price then 
        self.price = price
    end
    self.count = 1
    if count then self.count = count end
    self:createIcon()
end


function Item:createIcon()
    self.icon = deepcopy(texture["item.default"])
    if self.id == "Potatoes" then self.icon = deepcopy(texture["produce.potatoe"]) end
    if self.id == "Carrot" then self.icon = deepcopy(texture["produce.carrot"]) end
    if self.id == "Cabbage" then self.icon = deepcopy(texture["produce.cabbage"]) end
    if self.id == "Cucumber" then self.icon = deepcopy(texture["produce.cucumber"]) end
end


function Item:getName()
    return self.id
end


function Item:getSellPrice()
    return self.price
end


function Item:getCopy()
    return Item(deepcopy(self.id), 1, deepcopy(self.flags), deepcopy(self.price))
end

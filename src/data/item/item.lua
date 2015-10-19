
Item = Class{}


function Item:init(id, count, flags, price, description)
    self.flags = {}
    if flags then self.flags = flags end
    self.id = id
    self.price = 1 -- price in gold
    if price then 
        self.price = price
    end
    self.description = "Description"
    if description then self.description = description end
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


function Item:getCopy(amount)
    local count = 1
    if amount then count = amount end
    return Item(deepcopy(self.id), count, deepcopy(self.flags), deepcopy(self.price), deepcopy(self.description))
end

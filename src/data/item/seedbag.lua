
Seedbag = Class{}


function Seedbag:init(text)
    self.flags = { tool=true }
    self.level = 0
    self.id = "Seedbag"
    self.count = 1
    self.price = 50
    self.seed = nil --item id of current seed
    self.description = "Seedbag"
    if text then self.description = text end
    self:createIcon()
    self:nextSeed() -- select a seed of bag if any
end


function Seedbag:nextSeed()
    local i = self.seed
    if not i then i = 1 end
    local index = i + 1
    if index > #inventory.items then index = 1 end
    while not (index == i) do
        if inventory.items[index] and inventory.items[index].flags.seed then
            self.seed = index
            return
        end
        index = index + 1
        if index > #inventory.items then index = 1 end
    end
end


function Seedbag:createIcon()
    self.icon = inventory.icon.seedbag
end


function Seedbag:getName()
    return self.id
end


function Seedbag:use()
    if self.seed then
        local seed = inventory.items[self.seed]
        local seedsLeft = inventory:remove(seed.id, 1)
        if not seedsLeft then 
            self.seed = nil
        end
        return seed.id
    end
    return nil
end


function Seedbag:getCycles()
    return 1
end


function Seedbag:getSellPrice()
    return self.price --todo: factor in level and durability
end

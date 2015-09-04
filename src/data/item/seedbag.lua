
Seedbag = Class{}


function Seedbag:init()
    self.type = "tool"
    self.level = 0
    self.id = "Seedbag"
    self.count = 1
    self.seed = nil --item id of current seed
    self:createIcon()
    self:nextSeed() -- select a seed of bag if any
end


function Seedbag:nextSeed()
    local i = self.seed
    if not i then i = 1 end
    local index = i + 1
    while not (index == i) do
        if index > #inventory.items then index = 1 end
        if inventory.items[index] and inventory.items[index].type == "seed" then
            self.seed = index
            return
        end
        index = index + 1
    end
end


function Seedbag:createIcon()
    self.icon = inventory.icon.seedbag
end


function Seedbag:getName()
    return "Seedbag"
end


function Seedbag:use()
    return false
end

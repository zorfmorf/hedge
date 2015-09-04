
Seed = Class{}


function Seed:init(id, count)
    self.type = "seed"
    self.id = id
    self.count = 1
    if count then self.count = count end
    self:createIcon()
end


function Seed:createIcon()
    self.icon = deepcopy(texture["item.default"])
end


function Seed:getName()
    return self.id
end

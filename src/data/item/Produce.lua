
Produce = Class{}


function Produce:init(id, count)
    self.type = "produce"
    self.id = id
    self.count = 1
    if count then self.count = count end
    self:createIcon()
end


function Produce:createIcon()
    self.icon = deepcopy(texture["item.default"])
    if self.id == "Potatoes" then self.icon = deepcopy(texture["produce.potatoe"]) end
end

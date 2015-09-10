
Tool = Class{}


local baseToolD = 30


function Tool:init(id, level)
    self.flags = { tool=true, sellable = true }
    self.level = 0
    if level then self.level = level end
    self.id = id
    self.dmax = math.max(baseToolD, self.level * baseToolD * 2)
    self.durability = self.dmax
    self.count = 1
    self:createIcon()
end


function Tool:createIcon()
    self.icon = deepcopy(texture["item.default"])
    if inventory.icon and inventory.icon[self.id..tostring(self.level)] then 
        self.icon = inventory.icon[self.id..tostring(self.level)]
    end
end


function Tool:getName()
    local lv = " (Bronze)"
    if self.level == 1 then lv = " (Iron)" end
    if self.level == 2 then lv = " (Steel)" end
    return self.id..lv
end


function Tool:use(usage)
    local u = usage
    if not u then u = 1 end
    self.durability = self.durability - u
    return self.durability <= 0
end


function Tool:getSellPrice()
    return self.price --todo: factor in level and durability
end

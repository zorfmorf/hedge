
Tool = Class{}


local baseToolD = 30


function Tool:init(id, level, price, description)
    self.flags = { tool=true, sellable = true }
    self.level = 0
    if level then self.level = level end
    self.price = 1
    if price then self.price = price end
    self.id = id
    self.dmax = math.max(baseToolD, self.level * baseToolD * 2)
    self.durability = self.dmax
    self.description = "Description"
    if description then self.description = description end
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
    if self.level == 2 then lv = " (Iron)" end
    if self.level == 3 then lv = " (Steel)" end
    return self.id..lv
end


function Tool:use(usage)
    local u = usage
    if not u then u = 1 end
    self.durability = self.durability - u
    return self.durability <= 0
end


function Tool:getCycles()
    -- TODO: adjust for individual tools
    return 4 - self.level
end


function Tool:getSellPrice()
    return self.price --todo: factor in level and durability
end


function Tool:getCopy(amount)
    return self
end

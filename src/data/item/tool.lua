
Tool = Class{}


function Tool:init(id, level)
    self.type = "tool"
    self.level = 0
    if level then self.level = level end
    self.id = id
    self.dmax = math.max(10, self.level * 20)
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


function Tool:use()
    self.durability = self.durability - 1
    return self.durability <= 0
end

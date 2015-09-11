
Plant_Wheat = Class{}

function Plant_Wheat:init(tx, ty)
    self.type = "Wheat"
    if tx and ty then
        self.map = game.map.name
        self.tx = tx
        self.ty = ty
        self.days = 0
        self.state = 1
        self:update()
    end
end


-- update only when time elapsed
function Plant_Wheat:update(value)
    
    if value and value > 0 then 
        self.days = self.days + value
        if self.state < 5 then
            self.state = math.min(5, 1 + math.floor(self.days / 2))
        end
    end
    
    if game.map.name == self.map then
        local tile = game.map:getTile(self.tx, self.ty)
        if tile then
            tile.object = deepcopy(texture["plant.wheat."..self.state])
            tile.block = self.state > 2
        end
    end
end


function Plant_Wheat:isHarvestable()
    return self.state == 5
end


function Plant_Wheat:isHarvested()
    return self.state >= 6
end


function Plant_Wheat:harvest()
    self.state = 6
    local tile = game.map:getTile(self.tx, self.ty)
    inventory:add(itemCreator:getWheat(1))
end

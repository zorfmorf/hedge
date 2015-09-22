
Plant_Cucumber = Class{}

function Plant_Cucumber:init(tx, ty)
    self.type = "Cucumber"
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
function Plant_Cucumber:update(value)
    
    if value and value > 0 then 
        self.days = self.days + value
        if self.state < 4 then
            self.state = math.min(4, 1 + math.floor(self.days / 2))
        end
    end
    
    if game.map.name == self.map then
        local tile = game.map:getTile(self.tx, self.ty)
        if tile then
            tile.object = deepcopy(texture["plant.cucumber."..self.state])
            tile.block = self.state > 1 and self.state < 5
        end
    end
end


function Plant_Cucumber:isHarvestable()
    return self.state == 4
end


function Plant_Cucumber:isHarvested()
    return self.state >= 5
end


function Plant_Cucumber:harvest()
    self.state = 5
    inventory:add(itemCreator:getCucumber(1))
end
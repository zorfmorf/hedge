
Potatoe = Class{}

function Potatoe:init(tx, ty)
    self.type = "Potatoe"
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
function Potatoe:update(value)
    
    if value and value > 0 then 
        self.days = self.days + value
        if self.state < 4 then
            self.state = math.min(4, 1 + math.floor(self.days / 2))
        end
    end
    
    if game.map.name == self.map then
        local tile = game.map:getTile(self.tx, self.ty)
        if tile then
            tile.object = deepcopy(texture["plant.potatoe."..self.state])
            tile.block = self.state > 1 and self.state < 5
        end
    end
end


function Potatoe:isHarvestable()
    return self.state == 4
end


function Potatoe:harvest()
    self.state = 5
    local tile = game.map:getTile(self.tx, self.ty)
    inventory:add(Produce("Potatoes", 1))
end


Potatoe = Class{}

function Potatoe:init(tx, ty)
    self.tx = tx
    self.ty = ty
    self.days = 0
    self.state = 1
    self:update()
end


-- update only when time elapsed
function Potatoe:update(value)
    if value then 
        self.days = self.days + 1
        if self.state < 5 then
            self.state = math.max(1, math.floor(self.days / 2))
        end
    end
    -- DIRTY hack so that tiles are only updates if we are actually on the farm
    if game.map.name == "farm01" then
        local tile = game.map:getTile(self.tx, self.ty)
        if tile then
            tile.object = deepcopy(texture["plant.potatoe."..self.state])
        end
    end
end


function Potatoe:isHarvestable()
    return self.state == 5
end

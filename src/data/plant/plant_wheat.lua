
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
        self:updateVisuals()
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
    
end


-- needs to be done after updating state because
-- visuals depend on state of neighboring wheat plants
function Plant_Wheat:updateVisuals()
    if game.map.name == self.map then
        local tile = game.map:getTile(self.tx, self.ty)
        if tile then
            
            local tul = game.map:getTile(self.tx-1, self.ty-1)
            local tu = game.map:getTile(self.tx, self.ty-1)
            local tur = game.map:getTile(self.tx+1, self.ty-1)
            local tl = game.map:getTile(self.tx-1, self.ty)
            local tr = game.map:getTile(self.tx+1, self.ty)
            local tll = game.map:getTile(self.tx-1, self.ty+1)
            local td = game.map:getTile(self.tx, self.ty+1)
            local tlr = game.map:getTile(self.tx+1, self.ty+1)
            
            local pul = nil
            local pu = nil
            local pur = nil
            local pl = nil
            local pr = nil
            local pll = nil
            local pd = nil
            local plr = nil
            
            -- get surrounding plants
            for i,plant in ipairs(game.plants) do
                if game.map.name == plant.map and plant.type == self.type and plant.state == self.state then
                    
                    if plant.tx == self.tx-1 and plant.ty == self.ty-1 then pul = plant end
                    if plant.tx == self.tx and plant.ty == self.ty-1 then pu = plant end
                    if plant.tx == self.tx+1 and plant.ty == self.ty-1 then pur = plant end
                    if plant.tx == self.tx-1 and plant.ty == self.ty then pl = plant end
                    if plant.tx == self.tx+1 and plant.ty == self.ty then pr = plant end
                    if plant.tx == self.tx-1 and plant.ty == self.ty+1 then pll = plant end
                    if plant.tx == self.tx and plant.ty == self.ty+1 then pd = plant end
                    if plant.tx == self.tx+1 and plant.ty == self.ty+1 then plr = plant end
                    
                end
            end
            
            if self.state < 3 or self.state == 6 then
                tile.object = deepcopy(texture["plant.wheat."..self.state])
            end
            if self.state >= 3 and self.state <= 5 then
                tile.object = deepcopy(texture["plant.wheat."..self.state..".single"])
                if not pu then tu.object = deepcopy(texture["plant.wheat."..self.state..".single.u"]) end

                -- center tile
                if pl and pr and pll and pd and plr then
                    tile.object = deepcopy(texture["plant.wheat."..self.state..".m"])
                    if not pu then tu.object = deepcopy(texture["plant.wheat."..self.state..".u"]) end
                end
                
                -- left end
                if not pl and pr and pd then
                    tile.object = deepcopy(texture["plant.wheat."..self.state..".l"])
                    if not pu then tu.object = deepcopy(texture["plant.wheat."..self.state..".ul"]) end
                end
                
                -- right end
                if not pr and pl and pd then
                    tile.object = deepcopy(texture["plant.wheat."..self.state..".r"])
                    if not pu then tu.object = deepcopy(texture["plant.wheat."..self.state..".ur"]) end
                end
                
                -- lower left
                if not pl and not pll and not pd and pr and pu and pur then
                    tile.object = deepcopy(texture["plant.wheat."..self.state..".ll"])
                end
                
                -- lower
                if not pd and pl and pr and pu then
                    tile.object = deepcopy(texture["plant.wheat."..self.state..".d"])
                end
                
                -- lower right
                if not pr and not plr and not pd and pl and pu and pul then
                    tile.object = deepcopy(texture["plant.wheat."..self.state..".lr"])
                end
            end
            
            
            tile.block = self.state > 2 and self.state < 6
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

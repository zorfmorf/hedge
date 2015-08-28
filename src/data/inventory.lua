-- the global player inventory
-- an item is identified by a string
-- an inventory item is: { id=id, count=count}


local backpack = love.graphics.newImage("img/ui/backpack.png")
local font = love.graphics.newFont("font/alagard.ttf", 25)

inventory = {}


function inventory:init()
    self.items = {}
    self.count = 0
    self.maxitems = 10
end


function inventory:add(id, count)
    self.count = self.count + count
    player:addFloatingText(id.." x"..tostring(count))
    for i,item in ipairs(self.items) do
        if item.id == id then
            item.count = item.count + count
            return
        end
    end
    table.insert(self.items, { id=id, count=count })
end


function inventory:remove(id)
    for i,item in ipairs(self.items) do
        if item.id == id then
            item.count = item.count - 1
            self.count = self.count - 1
            if item.count < 1 then
                table.remove(self.items, i)
                return
            end
        end
    end
end


function inventory:removeAll(id)
    for i,item in ipairs(self.items) do
        if item.id == id then
            self.count = self.count - item.count
            table.remove(self.items, i)
            return
        end
    end
end


function inventory:draw()
    love.graphics.draw(backpack, screen.w - 15, screen.h - 10, 0, 1, 1, backpack:getWidth(), backpack:getHeight())
    love.graphics.setFont(font)
    love.graphics.setColor(Color.BLACK)
    local line = tostring(self.count).."/"..tostring(self.maxitems)
    love.graphics.print(line, screen.w - (16 + backpack:getWidth() / 2), screen.h - math.floor(1), 0, 1, 1, math.floor(font:getWidth(line) / 2), font:getHeight())
    love.graphics.setColor(Color.WHITE)
    love.graphics.print(line, screen.w - (15 + backpack:getWidth() / 2), screen.h - math.floor(2), 0, 1, 1, math.floor(font:getWidth(line) / 2), font:getHeight())
end


function inventory:save()
    -- TODO implement
end


function inventory:load()
    self:init() -- TODO implement
end

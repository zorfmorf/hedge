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
    self.open = false
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
    
    if self.open then
        love.graphics.setColor(Color.BLACK)
        love.graphics.rectangle("fill", screen.w * 0.25, screen.h * 0.25, screen.w * 0.5, screen.h * 0.5 )
        love.graphics.setColor(Color.WHITE)
        for i,item in ipairs(self.items) do
            love.graphics.print(item.id.." x"..item.count, screen.w * 0.25 + 10, screen.h * 0.25 + i * font:getHeight())
        end
    end
end


function inventory:trigger(value)
    if value then
        self.open = value
    else
        self.open = not self.open
    end
end


function inventory:save()
    local file = love.filesystem.newFile( C_MAP_CURRENT..C_MAP_INVENTORY )
    file:open("w")
    file:write(self.count..";")
    file:write(self.maxitems.."\n")
    for i,item in pairs(self.items) do
        file:write(item.id..';')
        file:write(tostring(item.count)..'\n')
    end
    file:close()
end


function inventory:load()
    self:init()
    if love.filesystem.isFile( C_MAP_CURRENT..C_MAP_INVENTORY )then
        local file = love.filesystem.newFile( C_MAP_CURRENT..C_MAP_INVENTORY )
        file:open("r")
        local firstLine = true
        for line in file:lines( ) do
            local values = line:split(";")
            if #values == 2 then
                if firstLine then
                    self.count = tonumber(values[1])
                    self.maxitems = tonumber(values[2])
                    firstLine = false
                end
                local item = {}
                item.id = values[1]
                item.count = tonumber(values[2])
                table.insert(self.items, item)
            end
        end
        file:close()
    end
end

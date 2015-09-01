-- the global player inventory
-- an item is identified by a string
-- an inventory item is: { id=id, count=count}


local backpack = nil
local font = love.graphics.newFont("font/alagard.ttf", 25)

inventory = {}


local function loadImages()
    local img = love.image.newImageData("img/icon/callum_icons.png")
    for i=0,5,1 do
        for j=0,2 do
            local dat = love.image.newImageData(C_INVENTORY_SIZE, C_INVENTORY_SIZE)
            dat:paste(img, 0, 0, i * C_INVENTORY_SIZE, j * C_INVENTORY_SIZE, C_INVENTORY_SIZE, C_INVENTORY_SIZE)
            if i == 0 and j == 0 then backpack = love.graphics.newImage(dat) end
        end
    end
end


function inventory:init()
    self.items = {}
    self.count = 0
    self.maxitems = 10
    self.open = false
    loadImages()
end


function inventory:add(itemobj)
    self.count = self.count + itemobj.count
    player:addFloatingText(itemobj.id.." x"..tostring(itemobj.count))
    for i,item in ipairs(self.items) do
        if item.id == itemobj.id then
            item.count = item.count + itemobj.count
            return
        end
    end
    table.insert(self.items, itemobj)
end


function inventory:remove(id, amount)
    for i,item in ipairs(self.items) do
        if item.id == id then
            local am = math.min(amount, item.count)
            item.count = item.count - am
            self.count = self.count - am
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
        file:write(item.type..';')
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
            if firstLine then
                self.count = tonumber(values[1])
                self.maxitems = tonumber(values[2])
                firstLine = false
            end
            local item = nil
            if values[1] == "produce" then item = Produce(values[2], tonumber(values[3])) end
            if item then
                table.insert(self.items, item)
            else
                log:msg("error", "Failed to load item line", line)
            end
        end
        file:close()
    end
end

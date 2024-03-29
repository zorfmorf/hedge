-- the global player inventory

local font = love.graphics.newFont("font/alagard.ttf", 20)

local container_title = love.graphics.newImage("img/ui/datetime.png")

Container = Class{}

local icon = nil -- will contain icons

local function loadIcons()
    if not icon then
        icon = {}
        local img = love.image.newImageData("img/icon/callum_icons_border.png")
        for i=0,5,1 do
            for j=0,2 do
                local dat = love.image.newImageData(C_INVENTORY_SIZE, C_INVENTORY_SIZE)
                dat:paste(img, 0, 0, i * C_INVENTORY_SIZE, j * C_INVENTORY_SIZE, C_INVENTORY_SIZE, C_INVENTORY_SIZE)
                if i == 0 and j == 0 then icon.backpack = love.graphics.newImage(dat) end
                if i == 1 and j == 0 then icon.seedbag = love.graphics.newImage(dat) end
                if i == 2 then icon["Spade"..tostring(j)] = love.graphics.newImage(dat) end
                if i == 3 then icon["Pickaxe"..tostring(j)] = love.graphics.newImage(dat) end
                if i == 4 then icon["Axe"..tostring(j)] = love.graphics.newImage(dat) end
                if i == 5 then icon["Scythe"..tostring(j)] = love.graphics.newImage(dat) end
            end
        end
    end
    return icon
end


function Container:init(id, flags, maxitems)
    self.items = {}
    self.id = id -- used for saving/retrieving container contents (if applicable)
    self.flags = flags
    self.count = 0 -- current item amount
    self.maxitems = 20 -- current maximum item amount
    if maxitems then self.maxitems = maxitems end
    self.money = 0
    self.tool = nil -- currently selected tool index
    self.box = nil -- contains inventory background draw object
    self.icon = loadIcons()
    self:reset()
end


-- Note: We don't want to always reset all containers on opening since the player inventory
-- should persist information such as which items was last selected
function Container:reset()
    self.offset = 0 -- how many items are "above" the inventory (scrolling)
    self.cursor = 1 -- item id the cursor is centered on
    self.confirmed = false -- if they buy/sell action is in confirm state
    self.confirmcount = 0
end


function Container:addMoney(amount)
    self.money = self.money + amount
    log:msg("verbose", "Added", amount, "money to container",self.id)
end


function Container:withdrawMoney(amount)
    local success = false
    if self.money >= amount then
        self.money = self.money - amount
        success = true
    end
    return success
end


function Container:hasFreeSlots(count, hideText)
    local v = 1
    if count then v = count end
    local free = self.maxitems - self.count
    if free < v and not hideText then player:addFloatingText("Inventory full") end
    return free >= v
end


function Container:hasItem(id)
    for i,item in pairs(self.items) do
        if item.id == id then return item end
    end
    return false
end


function Container:update(dt)
    if not self.box or not (self.box.w == screen.w and self.box.h == screen.h) then
        self.box = { w=screen.w, h=screen.h}
        local w = math.floor(screen.w * 0.9)
        local rest = w % C_TILE_SIZE
        if rest > 0 then w = w + (C_TILE_SIZE - rest) end
        local h = math.floor(screen.h * 0.8)
        rest = h % C_TILE_SIZE
        if rest > 0 then h = h + (C_TILE_SIZE - rest) end
        self.box.img = drawHelper:createGuiBox(w, h)
    end
end


function Container:add(itemobj)
    self.count = self.count + itemobj.count
    if itemobj.flags.tool then
        if self.id == inventory.id then player:addFloatingText(itemobj:getName()) end
        table.insert(self.items, itemobj)
        if not self.tool then self.tool = #self.items end
    else
        if self.id == inventory.id then
            player:addFloatingText(itemobj:getName().." x"..tostring(itemobj.count))
        end
        for i,item in ipairs(self.items) do
            if item.id == itemobj.id then
                item.count = item.count + itemobj.count
                return
            end
        end
        table.insert(self.items, itemobj)
        local tool = self:getTool()
        if tool and tool.id == "Seedbag" and not tool.seed and itemobj.flags.seed then
            tool:nextSeed()
        end
    end
end


-- Remove one or all items at given inventory position
function Container:removeAtPosition(pos, all)
    if all or self.items[pos].count <= 1 then
        self.count = self.count - self.items[pos].count
        table.remove(self.items, pos)
    else
        self.count = self.count - 1
        self.items[pos].count = self.items[pos].count - 1
    end
    self.cursor = math.min(self.cursor, #self.items)
end


-- Remove amount of item with the given id
-- returns true if there are still items of this id left
function Container:remove(id, amount)
    for i,item in ipairs(self.items) do
        if item.id == id then
            local am = math.min(amount, item.count)
            item.count = item.count - am
            self.count = self.count - am
            if item.flags.tool and i == self.tool then
                self.tool = nil
            end
            if item.count < 1 then
                table.remove(self.items, i)
                return false
            end
            return true
        end
    end
end


function Container:removeAll(id)
    for i,item in ipairs(self.items) do
        if item.id == id then
            self.count = self.count - item.count
            table.remove(self.items, i)
            if item.flags.tool and i == self.tool then
                self.tool = nil
            end
            return
        end
    end
end


function Container:hasItemWithFlag(flagToCheck)
    for i,item in ipairs(self.items) do
        if item.flags[flagToCheck] then return true end
    end
    return false
end


function Container:getTool()
    if self.tool and self.items[self.tool] then
        return self.items[self.tool]
    end
    return nil
end


function Container:selectAnyTool()
    for i=1,#self.items do
        if self.items[i].flags.tool then
            self.tool = i
            inventory:cycleSeed()
            return
        end
    end
end


function Container:nextTool()
    if self.tool then
        local i = self.tool + 1
        while not (i == self.tool) do
            if not self.items[i] then i = 1 end
            if self.items[i].flags.tool then
                self.tool = i
                inventory:cycleSeed()
                return
            end
            i = i + 1
        end
    else
        inventory:selectAnyTool()
    end
end


function Container:cycleSeed()
    if self.tool and self.items[self.tool].id == "Seedbag" then
        self.items[self.tool]:nextSeed()
    end
end


function Container:previousTool()
    if self.tool then
        local i = self.tool - 1
        while not (i == self.tool) do
            if not self.items[i] then i = #self.items end
            if self.items[i].flags.tool then
                self.tool = i
                inventory:cycleSeed()
                return
            end
            i = i - 1
        end
    else
        inventory:selectAnyTool()
    end
end


function Container:usesTool(tool)
    return self.tool and self.items[self.tool] and self.items[self.tool].id == tool
end


function Container:updateRowNumber()
    self.rownumber = math.floor((self.box.img:getHeight() - 10) /  (C_TILE_SIZE))
end


function Container:drawHud()
        
    -- draw backpack
    love.graphics.setColor(Color.WHITE)
    love.graphics.draw(icon.backpack, screen.w - 15, screen.h - 10, 0, 1, 1, icon.backpack:getWidth(), icon.backpack:getHeight() + 10)
    love.graphics.setFont(font)
    local line = tostring(self.count).."/"..tostring(self.maxitems)
    love.graphics.print(line, screen.w - (16 + icon.backpack:getWidth() / 2), screen.h - 1, 0, 1, 1, math.floor(font:getWidth(line) / 2), font:getHeight())
    
    -- draw tool / seedbag
    if self.tool and self.items[self.tool] then
        local line = self.items[self.tool]:getName()
        if self.items[self.tool].id == "Seedbag" then
            line = "No seeds selected"
            if self.items[self.tool].seed then
                line = self.items[self.items[self.tool].seed].id
            end
        end
        love.graphics.print(line, 5, screen.h - 1, 0, 1, 1, 0, font:getHeight())
        local img = self.items[self.tool].icon
        if img then love.graphics.draw(img, math.floor(font:getWidth(line) * 0.5), screen.h - font:getHeight(), 0, 1, 1, math.floor(img:getWidth() * 0.5), img:getHeight() - 10) end
    end
end


function Container:draw()
    
    if self.box then
        
        local dx = math.floor(screen.w * 0.05) + C_TILE_SIZE
        local dy = math.floor(screen.h * 0.1) + C_TILE_SIZE
        local mid = math.floor((self.box.img:getWidth() - C_TILE_SIZE * 2) * 0.5)
        local dh = self.box.img:getHeight() - C_TILE_SIZE * 2
        local fonthalf = math.floor(font:getHeight() / 2)
        
        love.graphics.setColor(Color.WHITE)
        love.graphics.draw(self.box.img, dx - C_TILE_SIZE, dy - C_TILE_SIZE)
        love.graphics.setFont(font)
        
        -- draw title box
        love.graphics.draw(container_title, dx - C_TILE_SIZE, dy - C_TILE_SIZE, 0, 1, 1, 0, container_title:getHeight())
        local title = "Inventory"
        if self.flags.buy then title = "Buying" end
        if self.flags.sell then title = "Selling" end
        if self.flags.store then title = "Storing" end
        if self.flags.retrieve then title = "Retrieving" end
        love.graphics.print(title, dx - C_TILE_SIZE + math.floor(container_title:getWidth() * 0.5), dy - C_TILE_SIZE - math.floor(container_title:getHeight() * 0.5), 0, 1, 1, math.floor(font:getWidth(title) * 0.5), fonthalf + 2)
        
        -- column descriptors
        love.graphics.print("ITEMS", dx + C_TILE_SIZE * 3, dy - 10, 0, 1, 1, font:getWidth("ITEMS"))
        local columndesc = "AMOUNT"
        if self.flags.buy then columndesc = "PRICE" end
        love.graphics.print(columndesc, dx + mid, dy - 10, 0, 1, 1, font:getWidth(columndesc) + 5)
        love.graphics.print("DESCRIPTION", dx + mid + C_TILE_SIZE * 3, dy - 10)
        
        -- list of items on the left
        local row = 1
        self:updateRowNumber()
        for i=1+self.offset,math.min(self.offset+self.rownumber, #self.items) do
            local item = self.items[i]
            
            local rowbuffer = math.floor(row * font:getHeight())
            
            if i == self.cursor then
                love.graphics.rectangle("fill", dx - 10, dy + rowbuffer + fonthalf, 5, 5)
            end
            
            local buffer = 0
            
            local amount = item.count
            if self.flags.buy then amount = item:getSellPrice() end
            
            love.graphics.print(amount, dx + mid, dy + rowbuffer, 0, 1, 1, font:getWidth(amount) + math.floor(C_TILE_SIZE * 0.5))
            love.graphics.print(item:getName(), dx, dy + rowbuffer)
            
            row = row + 1
        end
        
        -- money display
        love.graphics.print("Money: "..inventory.money, dx, dy + dh, 0, 1, 1, 0, 0)
        
        -- separator bar
        love.graphics.line(dx + mid, dy + font:getHeight(), dx + mid, dy + self.box.img:getHeight() - 2 * C_TILE_SIZE )
        
        -- item name on the right side
        if #self.items > 0 and self.items[self.cursor] then
            
            local item = self.items[self.cursor]
            love.graphics.print(item:getName(), dx + mid + C_TILE_SIZE, dy + C_TILE_SIZE * 1, 0, 1, 1, 0, fonthalf)
            
            love.graphics.printf(item.description, dx + mid + C_TILE_SIZE, dy + C_TILE_SIZE * 2, mid - C_TILE_SIZE, "left", 0, 1, 1, 0, fonthalf)
            
            -- button
            if self.flags.sell or self.flags.buy or self.flags.store or self.flags.retrieve then
                local text = "Sell"
                if self.flags.buy then 
                    text = "Buy"
                    if item.flags.tool and item.level > 1 then text = "Upgrade" end
                end
                if self.flags.store then text = "Store" end
                if self.flags.retrieve then text = "Retrieve" end
                if self.confirmed then
                    local price = item:getSellPrice() * self.confirmcount
                    text = text.." "..self.confirmcount
                    if self.flags.buy or self.flags.sell then
                        if self.flags.sell then price = math.floor(item:getSellPrice() * self.confirmcount * 0.5) end
                        text = text.." for "..price
                        if self.flags.buy and item.flags.tool then
                            if item.level > 1 then 
                                text = "Upgrade "..item.id.." for "..price
                            else
                                text = "Buy "..item.id.." for "..price
                            end
                        end
                    end
                    text = text.."?"
                    
                    if 1 < self.confirmcount or self.confirmcount < item.count then
                        text = text.." ("
                        if 1 < self.confirmcount then
                            text = text.."-: "..KEY_LEFT
                            if self.confirmcount < item.count then text = text..", " end
                        end
                        if self.confirmcount < item.count then
                            text = text.."+: "..KEY_RIGHT
                        end
                        text = text..")"
                    end
                    
                    if self.flags.sell and item.flags.tool then text = "" end
                    
                    local confirmtext = "Press "..KEY_USE.." to confirm"
                    love.graphics.setColor(Color.GREEN)
                    if self.flags.buy and price > inventory.money then
                        confirmtext = "Not enough money"
                        love.graphics.setColor(Color.RED)
                    end
                    if self.flags.sell and item.flags.tool then
                        confirmtext = "The merchant doesn't want to buy this"
                        love.graphics.setColor(Color.RED)
                    end
                    if (self.flags.buy or self.flags.retrieve) and not inventory:hasFreeSlots(self.confirmcount, true) then
                        confirmtext = "Not enough space in inventory"
                        love.graphics.setColor(Color.RED)
                    end
                    love.graphics.printf(confirmtext, dx + mid + C_TILE_SIZE, dy + dh, mid, "left", 0, 1, 1, 0, C_TILE_SIZE)
                    love.graphics.setColor(Color.WHITE)
                    love.graphics.print(text, dx + mid + C_TILE_SIZE, dy + dh, 0, 1, 1, 0, C_TILE_SIZE * 2)
                else
                    local action = "buy"
                    if self.flags.sell then action = "sell" end
                    if self.flags.store then action = "store" end
                    if self.flags.retrieve then action = "retrieve" end
                    local text = "Press "..KEY_USE.." to "..action
                    love.graphics.printf(text, dx + mid + C_TILE_SIZE, dy + dh, mid, "left", 0, 1, 1, 0, C_TILE_SIZE)
                end
            end
        end
    end
end


function Container:up()
    self:updateRowNumber()
    self.confirmed = false
    self.cursor = self.cursor - 1
    if self.offset >= self.cursor then self.offset = self.cursor - 1 end
    if self.cursor < 1 then 
        self.cursor = #self.items
        self.offset = math.max(0, #self.items - self.rownumber)
    end
end


function Container:down()
    self:updateRowNumber()
    self.confirmed = false
    self.cursor = self.cursor + 1
    if self.offset < self.cursor - self.rownumber then self.offset = self.offset + 1 end
    if self.cursor > #self.items then 
        self.cursor = 1
        self.offset = 0
    end
end


function Container:confirm()
    if self.confirmed and #self.items > 0 and self.items[self.cursor] then
        if self.flags.sell and not (self.items[self.cursor].flags.tool) then
            inventory:addMoney(math.floor(self.items[self.cursor]:getSellPrice() * self.confirmcount * 0.5))
            for i=1,self.confirmcount do
                self:removeAtPosition(self.cursor, false)
            end
        end
        if self.flags.buy then
            
            local item = self.items[self.cursor]
            
            if item.flags.tool then
                if (inventory:hasFreeSlots(1, true) or item.level > 1) and inventory:withdrawMoney(math.floor(item.price * self.confirmcount)) then
                    inventory:removeAll(item.id)
                    inventory:add(self.items[self.cursor])
                    self:removeAtPosition(self.cursor, true)
                    self:unconfirm()
                else
                    log:msg("verbose", "Not able to buy/upgrade tool", item.id, "Not enough money/inventory space")
                end
            else
                if inventory:hasFreeSlots(self.confirmcount, true) and inventory:withdrawMoney(math.floor(item.price * self.confirmcount)) then
                    inventory:add(item:getCopy(self.confirmcount))
                    self:unconfirm()
                else
                    log:msg("verbose", "Inventory full or not enough money to buy", item.id)
                end
            end
        end
        if self.flags.store or self.flags.retrieve then
            if self.target and self.target:hasFreeSlots(self.confirmcount, true) then
                self.target:add(self.items[self.cursor]:getCopy(self.confirmcount))
                for i=1,self.confirmcount do
                    self:removeAtPosition(self.cursor, false)
                end
            else
                log:msg("error", "Storage operation on container", self.id, "is missing target container information")
            end
        end
    else
        if #self.items > 0 and self.items[self.cursor] then
            self.confirmed = true
            self.confirmcount = 1
        else
            self.confirmed = false
        end
    end
end


function Container:reduceAmount()
    if self.confirmcount <= 1 then
        self.confirmed = false
    else
        self.confirmcount = self.confirmcount - 1
    end
end


function Container:increaseAmount()
    if #self.items > 0 then
        if self.confirmed then
            self.confirmcount = math.min(self.confirmcount + 1, self.items[self.cursor].count)
        else
            self:confirm()
        end
    end
end


function Container:unconfirm()
    self.confirmed = false
end


function Container:save()
    local filename = self.id .. C_FILE_SUFFIX
    local file = love.filesystem.newFile( C_MAP_CURRENT..filename )
    file:open("w")
    file:write(tostring(self.tool)..";")
    file:write(self.count..";")
    file:write(self.maxitems..";")
    file:write(self.money.."\n")
    for i,item in pairs(self.items) do
        local isfirst = true
        for key,value in pairs(item.flags) do
            if isfirst then
                isfirst = false
            else
                file:write(",")
            end
            file:write(key)
        end
        file:write(";")
        if item.flags.tool then
            file:write(item.id..","..tostring(item.level)..","..tostring(item.durability)..';')
        else
            file:write(item.id..';')
        end
        file:write(tostring(item.count)..';')
        file:write(tostring(item.price)..'\n')
    end
    file:close()
end


function Container:load()
    self:init(self.id, self.flags)
    local filename = self.id .. C_FILE_SUFFIX
    if love.filesystem.isFile( C_MAP_CURRENT..filename )then
        local file = love.filesystem.newFile( C_MAP_CURRENT..filename )
        file:open("r")
        local firstLine = true
        for line in file:lines( ) do
            local values = line:split(";")
            if firstLine then
                self.tool = tonumber(values[1])
                self.count = tonumber(values[2])
                self.maxitems = tonumber(values[3])
                self.money = tonumber(values[4])
                firstLine = false
            else
                local item = nil
                local flags = {}
                for i,v in ipairs(values[1]:split(',')) do
                    flags[v] = true
                end
                if flags.tool then
                    local vs = values[2]:split(",")
                    if vs[1] == "Seedbag" then
                        item = Seedbag()
                    else
                        item = Tool(vs[1], tonumber(vs[2]))
                        item.durability = tonumber(vs[3])
                    end
                else
                    item = Item(values[2], tonumber(values[3]), flags, tonumber(values[4]))
                end
                if item then
                    table.insert(self.items, item)
                else
                    log:msg("error", "Failed to load item line", line)
                end
            end
        end
        file:close()
    end
end


inventory = Container("inventory", {}) -- dirty

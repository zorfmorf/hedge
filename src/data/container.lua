-- the global player inventory

local font = love.graphics.newFont("font/alagard.ttf", 20)
local inventory_font = love.graphics.newFont("font/romulus.ttf", 22)

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
                if i == 2 then icon["Shovel"..tostring(j)] = love.graphics.newImage(dat) end
                if i == 3 then icon["Pickaxe"..tostring(j)] = love.graphics.newImage(dat) end
                if i == 4 then icon["Axe"..tostring(j)] = love.graphics.newImage(dat) end
                if i == 5 then icon["Scythe"..tostring(j)] = love.graphics.newImage(dat) end
            end
        end
    end
    return icon
end


function Container:init(id, flags)
    self.items = {}
    self.id = id -- used for saving/retrieving container contents (if applicable)
    self.flags = flags
    self.count = 0 -- current item amount
    self.maxitems = 20 -- current maximum item amount
    self.tool = nil -- currently selected tool index
    self.box = nil -- contains inventory background draw object
    self.icon = loadIcons()
    self.offset = 0 -- how many items are "above" the inventory (scrolling)
    self.cursor = 1 -- item id the cursor is centered on
end


function Container:hasFreeSlots(count, hideText)
    local v = 1
    if count then v = count end
    local free = self.maxitems - self.count
    if free < v and not hideText then player:addFloatingText("Inventory full") end
    return free >= v
end


function Container:update(dt)
    if not self.box or not (self.box.w == screen.w and self.box.h == screen.h) then
        self.box = { w=screen.w, h=screen.h}
        self.box.img = drawHelper:createGuiBox(math.floor(screen.w * 0.6), math.floor(screen.h * 0.6))
    end
end


function Container:add(itemobj)
    self.count = self.count + itemobj.count
    if itemobj.flags.tool then
        player:addFloatingText(itemobj:getName())
        table.insert(self.items, itemobj)
        if not self.tool then self.tool = #self.items end
    else
        player:addFloatingText(itemobj:getName().." x"..tostring(itemobj.count))
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


function Container:usedCurrentTool(usage)
    if self.tool and self.items[self.tool] then
        local destroyed = self.items[self.tool]:use(usage)
        if destroyed then
            player:addFloatingText(self.items[self.tool]:getName().." broke")
            table.remove(self.items, self.tool)
            self.count = self.count - 1
            inventory:selectAnyTool()
        end
    end
end


function Container:updateRowNumber()
    self.rownumber = math.floor((self.box.img:getHeight() - 10) /  (C_TILE_SIZE))
end


function Container:drawHud()
        
    -- draw backpack
    love.graphics.setColor(Color.WHITE)
    love.graphics.draw(icon.backpack, screen.w - 15, screen.h - 10, 0, 1, 1, icon.backpack:getWidth(), icon.backpack:getHeight())
    love.graphics.setFont(font)
    local line = tostring(self.count).."/"..tostring(self.maxitems)
    drawHelper:print(line, screen.w - (16 + icon.backpack:getWidth() / 2), screen.h - 1, 0, 1, 1, math.floor(font:getWidth(line) / 2), font:getHeight())
    
    -- draw tool / seedbag
    if self.tool then
        local img = self.items[self.tool].icon
        if img then love.graphics.draw(img, 15, screen.h - font:getHeight(), 0, 1, 1, 0, img:getHeight() - 10) end
        love.graphics.setColor(Color.BLACK)
        local line = tostring(self.items[self.tool].durability).."/"..tostring(self.items[self.tool].dmax)
        if self.items[self.tool].id == "Seedbag" then
            line = ""
            if self.items[self.tool].seed then
                line = self.items[self.items[self.tool].seed].id
            end
        end
        drawHelper:print(line, 15 + img:getWidth() / 2, screen.h - 1, 0, 1, 1, math.floor(font:getWidth(line) / 2), font:getHeight())
    end
end


function Container:draw()
    
    love.graphics.setColor(Color.WHITE)
    love.graphics.draw(self.box.img, math.floor(screen.w * 0.2), math.floor(screen.h * 0.2))
    love.graphics.setFont(inventory_font)
    local iconsize = C_TILE_SIZE
    local row = 0
    self:updateRowNumber()
    for i=1+self.offset,math.min(self.offset+self.rownumber, #self.items) do
        local item = self.items[i]
        local text = item:getName().." x"..item.count
        
        if i == self.cursor then
            love.graphics.setColor(Color.BLACK)
            love.graphics.rectangle("fill", math.floor(screen.w * 0.2 + 5), math.floor(screen.h * 0.2 + row * iconsize+12), math.floor(self.box.img:getWidth() * 0.5), C_TILE_SIZE )
        end
        
        -- draw icon first
        love.graphics.setColor(Color.WHITE)
        if item.flags.tool then
            iconsize = item.icon:getWidth() * 0.5
            love.graphics.draw(item.icon, math.floor(screen.w * 0.2 + 10), math.floor(screen.h * 0.2 + row * iconsize+10), 0, 0.5, 0.5)
        else
            local t = game.mapping[item.icon[1]][item.icon[2]][item.icon[3]]
            love.graphics.draw(game.atlas.img, game.atlas.quads[t[1]][t[2]], math.floor(screen.w * 0.2 + 10), math.floor(screen.h * 0.2 + row * iconsize+10))
        end
        
        drawHelper:print(text, math.floor(screen.w * 0.2 + 15 + iconsize), math.floor(screen.h * 0.2 + row * iconsize+10 + 0.5 * iconsize), 0, 1, 1, 0, math.floor(font:getHeight() / 2))
        
        row = row + 1
    end
    
    -- item name on the right sode
    if #self.items > 0 then
        local text = self.items[self.cursor]:getName()
        
        drawHelper:print(text, math.floor(screen.w * 0.2 + self.box.img:getWidth() * 0.5 + C_TILE_SIZE), math.floor(screen.h * 0.2) + C_TILE_SIZE, 0, 1, 1, 0, math.floor(font:getHeight() / 2))
        
        text = "Description"
        drawHelper:print(text, math.floor(screen.w * 0.2 + self.box.img:getWidth() * 0.5 + C_TILE_SIZE), math.floor(screen.h * 0.2) + C_TILE_SIZE * 2, 0, 1, 1, 0, math.floor(font:getHeight() / 2))
        
        -- button
        if self.flags.sell or self.flags.buy then
            
        end
    end
end


function Container:up()
    self:updateRowNumber()
    self.cursor = self.cursor - 1
    if self.offset >= self.cursor then self.offset = self.cursor - 1 end
    if self.cursor < 1 then 
        self.cursor = #self.items
        self.offset = math.max(0, #self.items - self.rownumber)
    end
end


function Container:down()
    self:updateRowNumber()
    self.cursor = self.cursor + 1
    if self.offset < self.cursor - self.rownumber then self.offset = self.offset + 1 end
    if self.cursor > #self.items then 
        self.cursor = 1
        self.offset = 0
    end
end


function Container:save()
    local file = love.filesystem.newFile( C_MAP_CURRENT..C_MAP_INVENTORY )
    file:open("w")
    file:write(tostring(self.tool)..";")
    file:write(self.count..";")
    file:write(self.maxitems.."\n")
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
    self:init("inventory", {})
    if love.filesystem.isFile( C_MAP_CURRENT..C_MAP_INVENTORY )then
        local file = love.filesystem.newFile( C_MAP_CURRENT..C_MAP_INVENTORY )
        file:open("r")
        local firstLine = true
        for line in file:lines( ) do
            local values = line:split(";")
            if firstLine then
                self.tool = tonumber(values[1])
                self.count = tonumber(values[2])
                self.maxitems = tonumber(values[3])
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

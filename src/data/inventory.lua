-- the global player inventory

local font = love.graphics.newFont("font/alagard.ttf", 20)
local inventory_font = love.graphics.newFont("font/romulus.ttf", 22)

inventory = {}


function inventory:loadImages()
    self.icon = {}
    local img = love.image.newImageData("img/icon/callum_icons_border.png")
    for i=0,5,1 do
        for j=0,2 do
            local dat = love.image.newImageData(C_INVENTORY_SIZE, C_INVENTORY_SIZE)
            dat:paste(img, 0, 0, i * C_INVENTORY_SIZE, j * C_INVENTORY_SIZE, C_INVENTORY_SIZE, C_INVENTORY_SIZE)
            if i == 0 and j == 0 then self.icon.backpack = love.graphics.newImage(dat) end
            if i == 1 and j == 0 then self.icon.seedbag = love.graphics.newImage(dat) end
            if i == 2 then self.icon["Shovel"..tostring(j)] = love.graphics.newImage(dat) end
            if i == 3 then self.icon["Pickaxe"..tostring(j)] = love.graphics.newImage(dat) end
            if i == 4 then self.icon["Axe"..tostring(j)] = love.graphics.newImage(dat) end
            if i == 5 then self.icon["Scythe"..tostring(j)] = love.graphics.newImage(dat) end
        end
    end
end


function inventory:init()
    self.items = {}
    self.count = 0 -- current item amount
    self.maxitems = 10 -- current maximum item amount
    self.open = false -- if the inventory is open (list of all items)
    self.tool = nil -- currently selected tool index
    self.box = nil -- contains inventory background draw object
    self:loadImages()
end


function inventory:update(dt)
    if not self.box or not (self.box.w == screen.w and self.box.h == screen.h) then
        self.box = { w=screen.w, h=screen.h}
        self.box.img = drawHelper:createGuiBox(math.floor(screen.w * 0.6), math.floor(screen.h * 0.6))
    end
end


function inventory:add(itemobj)
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
function inventory:remove(id, amount)
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


function inventory:removeAll(id)
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


function inventory:getTool()
    if self.tool and self.items[self.tool] then
        return self.items[self.tool]
    end
    return nil
end


function inventory:selectAnyTool()
    for i=1,#self.items do
        if self.items[i].flags.tool then
            self.tool = i
            inventory:cycleSeed()
            return
        end
    end
end


function inventory:nextTool()
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


function inventory:cycleSeed()
    if self.tool and self.items[self.tool].id == "Seedbag" then
        self.items[self.tool]:nextSeed()
    end
end


function inventory:previousTool()
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


function inventory:usesTool(tool)
    return self.tool and self.items[self.tool] and self.items[self.tool].id == tool
end


function inventory:usedCurrentTool(usage)
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


function inventory:draw()
    
    -- draw backpack
    love.graphics.draw(self.icon.backpack, screen.w - 15, screen.h - 10, 0, 1, 1, self.icon.backpack:getWidth(), self.icon.backpack:getHeight())
    love.graphics.setFont(font)
    love.graphics.setColor(Color.BLACK)
    local line = tostring(self.count).."/"..tostring(self.maxitems)
    love.graphics.print(line, screen.w - (16 + self.icon.backpack:getWidth() / 2), screen.h - 1, 0, 1, 1, math.floor(font:getWidth(line) / 2), font:getHeight())
    love.graphics.setColor(Color.WHITE)
    love.graphics.print(line, screen.w - (15 + self.icon.backpack:getWidth() / 2), screen.h - 2, 0, 1, 1, math.floor(font:getWidth(line) / 2), font:getHeight())
    
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
        love.graphics.print(line, 15 + img:getWidth() / 2, screen.h - 1, 0, 1, 1, math.floor(font:getWidth(line) / 2), font:getHeight())
        love.graphics.setColor(Color.WHITE)
        love.graphics.print(line, 14 + img:getWidth() / 2, screen.h - 2, 0, 1, 1, math.floor(font:getWidth(line) / 2), font:getHeight())
    end
    
    if self.open then
        love.graphics.setColor(Color.WHITE)
        love.graphics.draw(self.box.img, math.floor(screen.w * 0.2), math.floor(screen.h * 0.2))
        love.graphics.setFont(inventory_font)
        local col = 0
        local row = 0
        local rowwidth = 0
        for i,item in ipairs(self.items) do
            
            local text = item:getName().." x"..item.count
            
            -- draw icon first
            local iconsize = C_TILE_SIZE
            love.graphics.setColor(Color.WHITE)
            if item.flags.tool then
                iconsize = item.icon:getWidth() * 0.5
                love.graphics.draw(item.icon, math.floor(screen.w * 0.2 + 10 + col), math.floor(screen.h * 0.2 + row * iconsize+10), 0, 0.5, 0.5)
            else
                local t = game.mapping[item.icon[1]][item.icon[2]][item.icon[3]]
                love.graphics.draw(game.atlas.img, game.atlas.quads[t[1]][t[2]], math.floor(screen.w * 0.2 + 10 + col), math.floor(screen.h * 0.2 + row * iconsize+10))
            end
            
            rowwidth = math.max(inventory_font:getWidth(text) + iconsize + 5, rowwidth)
            
            love.graphics.setColor(Color.BLACK)
            love.graphics.print(text, math.floor(screen.w * 0.2 + 15 + col + iconsize), math.floor(screen.h * 0.2 + row * iconsize+10 + 0.5 * iconsize), 0, 1, 1, 0, math.floor(font:getHeight() / 2))
            
            love.graphics.setColor(Color.WHITE)
            love.graphics.print(text, math.floor(screen.w * 0.2 + 16 + col + iconsize), math.floor(screen.h * 0.2 + row * iconsize+11 + 0.5 * iconsize), 0, 1, 1, 0, math.floor(font:getHeight() / 2))
            
            row = row + 1
            if row * iconsize + 30 > self.box.img:getHeight() then
                row = 0
                col = col + rowwidth + 20
                rowwidth = 0
            end
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
    file:write(self.tool..";")
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


function inventory:load()
    self:init()
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

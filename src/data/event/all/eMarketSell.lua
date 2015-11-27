-- start the market sell dialog

local function init()
    
end


local function walk(x, y)
    
end


local function use(x, y)
    if timeHandler.getHour() >= 12 then
        st_ingame:startDialog("d_marketSell", 1, x, y)
        return
    end
    if inventory:hasItemWithFlag("produce") == false then
        st_ingame:startDialog("d_marketSell", 2, x, y)
        return
    end
    st_ingame:startDialog("d_marketSell", 3, x, y)
end


return {
        id = 12,
        init = init,
        use = use,
        walk = walk
    }

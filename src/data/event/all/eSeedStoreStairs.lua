-- seed store conversation

local function init()
    
end


local function walk(x, y)
    st_ingame:startDialog("d_karen", 2, x+3, y)
    entityHandler.get(3).dir = "left"
end


local function use(x, y)
    
end


return {
        init = init,
        use = use,
        walk = walk
    }
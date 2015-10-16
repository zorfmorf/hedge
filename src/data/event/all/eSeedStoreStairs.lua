-- seed store conversation

local function init()
    
end


local function walk()
    st_ingame:startDialog("d_karen", 2)
    entityHandler.get(3).dir = "left"
end


local function use()
    
end


return {
        id = 7,
        init = init,
        use = use,
        walk = walk
    }
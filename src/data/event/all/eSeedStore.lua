-- seed store conversation

local function init()
    
end


local function walk()
    
end


local function use(tx, ty)
    st_ingame:startDialog("d_karen", 3, tx, ty)
end


return {
        id = 6,
        init = init,
        use = use,
        walk = walk
    }
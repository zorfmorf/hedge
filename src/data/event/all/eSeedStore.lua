-- seed store conversation

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    st_ingame:startDialog("d_karen", 3, tx, ty-1)
end


return {
        id = 6,
        init = init,
        use = use,
        walk = walk
    }

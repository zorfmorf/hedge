-- tool store conversation

local function init()
    
end


local function walk()
    
end


local function use(tx, ty)
    st_ingame:startDialog("d_tim", 2, tx, ty-1)
end


return {
        id = 8,
        init = init,
        use = use,
        walk = walk
    }

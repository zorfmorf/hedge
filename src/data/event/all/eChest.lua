-- the chest which can hold all the player items

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    st_ingame:startDialog("d_chest", 1, tx, ty)
end


return {
        id = 2,
        init = init,
        use = use,
        walk = walk
    }
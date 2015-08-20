-- a big stone on the field

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    st_ingame:startDialog("d_example")
end


return {
        id = 1,
        init = init,
        use = use,
        walk = walk
    }
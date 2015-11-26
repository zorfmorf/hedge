-- sleeping in bed

local function init()
    
end


local function walk(x, y)
    st_ingame:startDialog("d_bed", 1, x, y)
end


local function use(x, y)
    
end


return {
        id = 3,
        init = init,
        use = use,
        walk = walk
    }

-- pawn store conversation

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    st_ingame:startDialog("d_lew", 1, tx, ty+1)
end


return {
        init = init,
        use = use,
        walk = walk
    }

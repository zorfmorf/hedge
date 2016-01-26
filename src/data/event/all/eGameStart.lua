-- a big stone on the field

local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    if var.get("tutorial") == 0 then
        st_ingame:startDialog("d_init", 1, tx, ty+1)
    end
end


return {
        init = init,
        use = use,
        walk = walk
    }
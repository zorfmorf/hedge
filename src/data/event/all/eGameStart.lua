-- a big stone on the field

local function init()
    
end


local function walk(tx, ty)
    
    -- block from leaving shack
    if var.get("tutorial") == 2 and ty == 1 then
        st_ingame:startDialog("d_init", 99, tx, ty)
    end
    if var.get("tutorial") == 3 and ty == 1 then
        st_ingame:startDialog("d_init", 66, tx, ty)
    end
    if var.get("tutorial") == 4 and ty == 1 then
        st_ingame:startDialog("d_init", 55, tx, ty)
        var.set("tutorial", 5)
    end
    
    -- inspect shack
    if var.get("tutorial") == 1 and game.map.name == "home" then
        st_ingame:startDialog("d_init", 7, tx, ty)
        var.set("tutorial", 2)
    end
    
    -- block south movement
    if var.get("tutorial") == 1 and game.map.name == "farm" and ty > 4 then
        st_ingame:startDialog("d_init", 99, tx, ty)
    end
    
end


local function use(tx, ty)
    
    -- arrival dialog
    if var.get("tutorial") == 0 then
        st_ingame:startDialog("d_init", 1, tx, ty+1)
        var.set("tutorial", 1)
    end
    
    -- use cupboard
    if var.get("tutorial") == 2 and tx ==-2 and var.get("tutorial_table") == 0 then
        local id = 77
        if var.get("tutorial_desk") == 1 then id = 88 end
        st_ingame:startDialog("d_init", id, tx, ty+1)
        var.set("tutorial_table", 1)
        if var.get("tutorial_desk") == 1 then var.set("tutorial", 3) end
    end
    
    -- use table
    if var.get("tutorial") == 2 and tx ==0 and var.get("tutorial_desk") == 0 then
        local id = 77
        if var.get("tutorial_table") == 1 then id = 88 end
        st_ingame:startDialog("d_init", id, tx, ty+1)
        var.set("tutorial_desk", 1)
        if var.get("tutorial_table") == 1 then var.set("tutorial", 3) end
    end
    
end


return {
        init = init,
        use = use,
        walk = walk
    }
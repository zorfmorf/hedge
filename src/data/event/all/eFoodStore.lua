-- food store conversation


local function init()
    
end


local function walk(tx, ty)
    
end


local function use(tx, ty)
    local container = Container("tool_store", { buy=true })
    container:add(itemCreator:getWheatBread(99))
    st_ingame.container = container
    container:update(0)
end


return {
        init = init,
        use = use,
        walk = walk
    }

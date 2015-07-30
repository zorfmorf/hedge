-- a big stone on the field

local function init()
    
end


local function walk()
    print( "stop walking on me!")
end


local function use()
    st_ingame:startDialog(Dialog(1))
end


return {
        id = 1,
        init = init,
        use = use,
        walk = walk
    }
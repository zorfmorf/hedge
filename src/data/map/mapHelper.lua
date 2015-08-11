
mapHelper = {}

function mapHelper:createBorder(tx, ty, brush)
    print ( "inspecting", tx, ty)
    
    local tile = game.map:getTile(tx, tx)
    local block = true
    if tile then block = tile.block end
    if brush:onTile(tx, ty) then return end
    
    -- side.l
    if brush.border.side.l then
        if not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx, ty + 1) and
           not brush:onTile(tx - 1, ty) and
           brush:onTile(tx + 1, ty) then
            game.map:setTile(tx, ty, nil, brush.border.side.l, nil, nil, block)
        end
    end
    
    -- side.r
    if brush.border.side.r then
        if not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx, ty + 1) and
           not brush:onTile(tx + 1, ty) and
           brush:onTile(tx - 1, ty) then
            game.map:setTile(tx, ty, nil, brush.border.side.r, nil, nil, block)
        end
    end
    
    -- side.u
    if brush.border.side.u then
        if not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           brush:onTile(tx, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.side.u, nil, nil, block)
        end
    end
    
    -- side.d
    if brush.border.side.d then
        if not brush:onTile(tx, ty + 1) and
           not brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           brush:onTile(tx, ty - 1) then
            game.map:setTile(tx, ty, nil, brush.border.side.d, nil, nil, block)
        end
    end
    
    -- inner.ul
    if brush.border.inner.ul then
        if brush:onTile(tx, ty - 1) and
           brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           not brush:onTile(tx, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.inner.ul, nil, nil, block)
        end
    end
    
    -- inner.ur
    if brush.border.inner.ur then
        if brush:onTile(tx, ty - 1) and
           not brush:onTile(tx - 1, ty) and
           brush:onTile(tx + 1, ty) and
           not brush:onTile(tx, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.inner.ur, nil, nil, block)
        end
    end
    
    -- inner.ll
    if brush.border.inner.ll then
        if not brush:onTile(tx, ty - 1) and
           brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           brush:onTile(tx, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.inner.ll, nil, nil, block)
        end
    end
    
    -- inner.lr
    if brush.border.inner.lr then
        if not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx - 1, ty) and
           brush:onTile(tx + 1, ty) and
           brush:onTile(tx, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.inner.lr, nil, nil, block)
        end
    end
    
    -- outer.ul
    if brush.border.outer.ul then
        if not brush:onTile(tx - 1, ty - 1) and
           not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx + 1, ty - 1) and
           not brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           not brush:onTile(tx - 1, ty + 1) and
           not brush:onTile(tx, ty + 1) and
           brush:onTile(tx + 1, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.outer.ul, nil, nil, block)
        end
    end
    
    -- outer.ur
    if brush.border.outer.ur then
        if not brush:onTile(tx - 1, ty - 1) and
           not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx + 1, ty - 1) and
           not brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           brush:onTile(tx - 1, ty + 1) and
           not brush:onTile(tx, ty + 1) and
           not brush:onTile(tx + 1, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.outer.ur, nil, nil, block)
        end
    end
    
    -- outer.ll
    if brush.border.outer.ll then
        if not brush:onTile(tx - 1, ty - 1) and
           not brush:onTile(tx, ty - 1) and
           brush:onTile(tx + 1, ty - 1) and
           not brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           not brush:onTile(tx - 1, ty + 1) and
           not brush:onTile(tx, ty + 1) and
           not brush:onTile(tx + 1, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.outer.ll, nil, nil, block)
        end
    end
    
    -- outer.lr
    if brush.border.outer.lr then
        if brush:onTile(tx - 1, ty - 1) and
           not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx + 1, ty - 1) and
           not brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           not brush:onTile(tx - 1, ty + 1) and
           not brush:onTile(tx, ty + 1) and
           not brush:onTile(tx + 1, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.outer.lr, nil, nil, block)
        end
    end
end
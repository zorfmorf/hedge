
mapHelper = {}

function mapHelper:createBorder(tx, ty, brush)
    
    local tile = game.map:getTile(tx, tx)
    if brush:onTile(tx, ty) then return end
    
    -- side.l
    if brush.border.side.l then
        if not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx, ty + 1) and
           not brush:onTile(tx - 1, ty) and
           brush:onTile(tx + 1, ty) then
            game.map:setTile(tx, ty, nil, brush.border.side.l, nil, nil, true)
        end
    end
    
    -- side.r
    if brush.border.side.r then
        if not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx, ty + 1) and
           not brush:onTile(tx + 1, ty) and
           brush:onTile(tx - 1, ty) then
            game.map:setTile(tx, ty, nil, brush.border.side.r, nil, nil, true)
        end
    end
    
    -- side.u
    if brush.border.side.u then
        if not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           brush:onTile(tx, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.side.u, nil, nil, true)
        end
    end
    
    -- side.d
    if brush.border.side.d then
        if not brush:onTile(tx, ty + 1) and
           not brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           brush:onTile(tx, ty - 1) then
            game.map:setTile(tx, ty, nil, brush.border.side.d, nil, nil, true)
        end
    end
    
    -- inner.ul
    if brush.border.inner.ul then
        if brush:onTile(tx, ty - 1) and
           brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           not brush:onTile(tx, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.inner.ul, nil, nil, true)
        end
    end
    
    -- inner.ur
    if brush.border.inner.ur then
        if brush:onTile(tx, ty - 1) and
           not brush:onTile(tx - 1, ty) and
           brush:onTile(tx + 1, ty) and
           not brush:onTile(tx, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.inner.ur, nil, nil, true)
        end
    end
    
    -- inner.ll
    if brush.border.inner.ll then
        if not brush:onTile(tx, ty - 1) and
           brush:onTile(tx - 1, ty) and
           not brush:onTile(tx + 1, ty) and
           brush:onTile(tx, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.inner.ll, nil, nil, true)
        end
    end
    
    -- inner.lr
    if brush.border.inner.lr then
        if not brush:onTile(tx, ty - 1) and
           not brush:onTile(tx - 1, ty) and
           brush:onTile(tx + 1, ty) and
           brush:onTile(tx, ty + 1) then
            game.map:setTile(tx, ty, nil, brush.border.inner.lr, nil, nil, true)
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
            game.map:setTile(tx, ty, nil, brush.border.outer.ul, nil, nil, true)
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
            game.map:setTile(tx, ty, nil, brush.border.outer.ur, nil, nil, true)
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
            game.map:setTile(tx, ty, nil, brush.border.outer.ll, nil, nil, true)
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
            game.map:setTile(tx, ty, nil, brush.border.outer.lr, nil, nil, true)
        end
    end
end


function mapHelper:createObject(tx, ty, brush)
    for x=1,brush.xsize do
        for y=1,brush.ysize do
            if brush.tile[x] and brush.tile[x][y] then
                local tile = game.map:getTile(tx + (x-1), ty + (y-1))
                if tile then
                    if brush.tile[x][y].overlay then
                        tile.overlay = brush.tile[x][y]
                    else
                        tile.object = brush.tile[x][y]
                    end
                else
                    if brush.tile[x][y].overlay then
                        game.map:setTile(tx + (x-1), ty + (y-1), nil, nil, nil, brush.tile[x][y])
                    else
                        game.map:setTile(tx + (x-1), ty + (y-1), nil, nil, brush.tile[x][y])
                    end
                end
            end
        end
    end
end

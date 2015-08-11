
local brushes = {} -- all tile brushes
local brush = 0 -- current brush
local last = {} -- 10 last used brushes
local atlanti = nil -- list of all atlantis

brushHandler = {}

function brushHandler.init()
    
    atlanti = tilesetreader:read()
    
    brushes = {}
    table.insert(brushes, Brush(1)) -- default brush
    brush = 1
    brushes[1].tiles = { {1, 21, 5}, {1, 22, 5}, {1, 23, 5} }
    
    -- fill list of last used brushes
    last = {}
    for i,brush in pairs(brushes) do
        table.insert(last, i)
        if i >= 10 then break end
    end
end


function brushHandler.clear()
    brushes = {}
end


function brushHandler.currentBrushId()
    return brush
end


function brushHandler.getCurrentBrush()
    return brushes[brush]
end


function brushHandler.getBrushes()
    return brushes
end


function brushHandler.delete(id)
    brushes[id] = nil
    for i=10,1,-1 do
        if last[i] then
            if last[i] == id then
                table.remove(last, i)
            end
        end
    end
end


function brushHandler.getBrush(i)
    return brushes[i]
end


function brushHandler.setBrush(brush, i)
    if i then
        brushes[i] = brush
        brush.id = i
    else
        local index = #brushes
        table.insert(brushes, brush)
        brush.id = index + 1
    end
    
    -- small hack to fix naming issue for loaded brushes
    if brush.name == "Brush0" then brush.name = "Brush"..brush.id end
end


function brushHandler.selectBrush(i)
    brush = i
    table.insert(last, 1, i)
    for index=2,10 do
        if last[index] == i then
            table.remove(last, index)
            return
        end
    end
    while #last > 10 do
        table.remove(last)
    end
end


function brushHandler.getRecentBrushes()
    return last
end


function brushHandler.setRecentBrushes(newlist)
    last = newlist
end


function brushHandler.getAtlanti()
    return atlanti
end

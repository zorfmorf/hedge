
st_edit = {}

local map = nil -- map information
local atlanti = nil -- set of texture atlanti

function st_edit:enter()
    map = maploader:read()
    atlanti = tilesetreader:read()
    
    map:draw()
end


function st_edit:update(dt)
    
end


function st_edit:draw()
    love.graphics.draw(atlanti[1].batch, 0, 0)
    love.graphics.print(love.timer.getFPS(), screen.w - 100, 10)
end

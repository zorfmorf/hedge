
st_edit = {}

local map = nil


function st_edit:enter()
    map = maploader:read()
end


function st_edit:update(dt)
    
end


function st_edit:draw()
    love.graphics.rectangle("line", 10, 10, 200, 20)
end

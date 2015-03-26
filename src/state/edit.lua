
st_edit = {}

local map = nil


function st_edit:enter()
    map = maploader:read()
end


function st_edit:update(dt)
    
end


function st_edit:draw()
    map:draw()
end

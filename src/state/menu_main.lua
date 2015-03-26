
st_menu_main = {}

function st_menu_main:enter()
    
    Gui.group.default.spacing = 5
    
end

function st_menu_main:update(dt)
    
    screen:update()
    
    Gui.group.push{grow = "down", pos = {screen.w * 0.2, screen.h * 0.4}}
        
        Gui.Button{text = "Play"}
        if C_DEBUG and Gui.Button{text = "Editor"} then Gamestate.switch(st_edit) end
        Gui.Button{text = "Options"}
        if Gui.Button{text = "Exit"} then love.event.push("quit") end
        
    Gui.group.pop{}
    
end

function st_menu_main:draw()
    Gui.core.draw()
end

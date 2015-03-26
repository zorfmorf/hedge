
screen = {}

screen.w = love.graphics.getWidth()
screen.h = love.graphics.getHeight()

function screen:update()
    screen.w = love.graphics.getWidth()
    screen.h = love.graphics.getHeight()
end
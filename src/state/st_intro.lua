
st_intro = {}

local timer = 0
local maxtime = 20
local font = love.graphics.newFont("font/alagard.ttf", 40)

local lines = {
                "Fandel is a small border town, untouched by the war so far.",
                "To the west lies an abandoned farmstead, slowly deteriorating with every passing year.",
                "But one day a foreign woman arrives, claiming to be the sole heir to the estate."
            }
local endline = "Press [any key] to start the game"

function st_intro:enter()
    maxtime = #lines * C_LINE_TIME
    timer = maxtime
end


function st_intro:update(dt)
    
    screen:update()
    timer = timer - dt
    
end


function st_intro:draw()
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(Color.BLACK)
    
    local buffer = 0
    
    for i,line in ipairs(lines) do
        local v = math.max(maxtime - (i - 1) * C_LINE_TIME - timer, 0)
        love.graphics.setColor(255, 255, 255, math.floor(255 * math.min(v, C_LINE_TIME) / C_LINE_TIME))
        local width = math.floor(screen.w * 0.8)
        local w,l = font:getWrap(line, width)
        love.graphics.printf(line, math.floor(screen.w * 0.5), 50 + buffer, width, "center", 0, 1, 1, math.floor(w * 0.5))
        buffer = buffer + (l + 1) * font:getHeight()
    end
    
    if timer <= 0 then
        love.graphics.setColor(Color.WHITE)
        love.graphics.print(endline, math.floor(screen.w * 0.5), screen.h - 10 - font:getHeight(), 0, 1, 1, math.floor(font:getWidth(endline) * 0.5))
    end
    
end


function st_intro:keypressed(key, isrepeat)
    if not isrepeat then
        if (key == KEY_RETURN and timer > 0) then
            timer = 0
        else
            Gamestate.switch(st_ingame)
        end
    end
end

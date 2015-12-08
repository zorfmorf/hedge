
local name = "Market woman"
local varname = "t_marketwoman"

local messages = {}
messages[1] = "What a nice day at the market"
messages[2] = "I have five sons at home and you wouldn't belive how much they eat"
messages[3] = "No time, I need to buy groceries"
messages[4] = "Finally some quality time for myself"

local lines = {}

lines[1] = { name = name, cond = function() return var.get(varname) end, text = function() 
    return messages[math.max(1, timeHandler.getDay() % #messages)] end, target=-1 }
lines[2] = { name = name, text = function() return "I have never seen you before. Are you new in town?" end }
lines[3] = { name = true, text = function() return "Yes, I've just arrived last night. I inherited the old Mason estate." end, player = true }
lines[4] = { name = name, text = function() return "Oh, is that so? Well you got your work cut out for you." end, func = function() var.set(varname, 1)   end }

return lines

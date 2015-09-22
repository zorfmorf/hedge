
local lines = {}

lines[1] = { name = "Daphne", text = function() return "This is a dialog line" end }
lines[2] = { text = function() return "This is another dialog line" end, avatar = true }
lines[3] = { text = function() return "Choose one of these options:" end, 
                    options={ 
                        { target=4, text="First option, read on", func=function() print("Function call") end }, 
                        { target=6, text="Second option, jump to end" }
                    }
                }
lines[4] = { text = function() return "This is another dialog line" end }
lines[5] = { text = function() return "This is yet another dialog line" end }
lines[6] = { text = function() return "This is the last dialog line" end }

return lines

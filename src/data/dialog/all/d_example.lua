
local lines = {}

lines[1] = { name = "Daphne", text = "This is a dialog line" }
lines[2] = { text = "This is another dialog line", avatar = true }
lines[3] = { text = "Choose one of these options:", 
                    options={ 
                        { target=4, text="First option, read on", func=function() print("Function call") end }, 
                        { target=6, text="Second option, jump to end" }
                    }
                }
lines[4] = { text = "This is another dialog line" }
lines[5] = { text = "This is yet another dialog line" }
lines[6] = { text = "This is the last dialog line" }

return lines


local lines = {}

lines[1] = { text = "Dou you want to go to sleep?", 
                options={ 
                    { text="Sleep until tomorrow", func=function() 
                            st_ingame.transition = Transition("fade_out", timeHandler.sleep())
                        end }, 
                    { text="Cancel" }
                }
            }

return lines

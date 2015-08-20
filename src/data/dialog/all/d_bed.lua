
local lines = {}

lines[1] = { text = "Dou you want to go to sleep?", 
                options={ 
                    { target=2, text="Sleep until tomorrow", func=function() 
                            st_ingame.transition = Transition("fade_out", function() 
                                    timeHandler.sleep()
                                    st_ingame.dialog = nil
                                end)
                        end }, 
                    { target=2, text="Cancel" }
                }
            }

return lines

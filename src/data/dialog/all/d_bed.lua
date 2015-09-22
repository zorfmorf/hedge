
local lines = {}

lines[1] = { text = function() return "Do you want to go to sleep?" end, 
                options={ 
                    { target=3, text="Sleep until tomorrow", func=function() 
                            st_ingame.transition = Transition("fade_out", function() 
                                    timeHandler.sleep()
                                    st_ingame.dialog = nil
                                end)
                        end }, 
                    { target=2, text="This option only appears with free inventory space", cond=function() return inventory:hasFreeSlots(1, true) end },
                    { target=3, text="Cancel" }
                }
            }
lines[2] = { text = function() return "Looks like you had some free inventory space!" end, name="Daphne", avatar=true }

return lines


local lines = {}

lines[1] = { text = function() return "I should check for valuables first" end, cond = function() return var.get("tutorial") == 2 end, target=-1 }
lines[2] = { text = function() return "Do you want to go to sleep?" end,
                options={ 
                    { target=-1, text="Sleep until tomorrow", func=function()
                            if var.get("tutorial") == 3 then var.set("tutorial", 4) end
                            st_ingame.transition = Transition("fade_out", function() 
                                    timeHandler.sleep()
                                    st_ingame.dialog = nil
                                end)
                        end },
                    { target=-1, text="Don't sleep" }
                }
            }
lines[3] = { text = function() return "Looks like you had some free inventory space!" end, name="Daphne" }

return lines

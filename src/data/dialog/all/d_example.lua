
local lines = {}

--[[--
    Remember that depending on the event that launches the dialog, it might not start with line 1
    line definition. entries with * are required, others can be omitted completely, boolean default it false
    line: { 
            name = [boolean || string]  : The name of the speaker or (if boolean) will use the player name
            text = [function]           : Function that needs to return a string (the text to be displayed in the bubble) or nil
            player = [boolean]          : If true, the bubble for this line will be centered on the player
            cond = [function]           : If defined, line will be ignored if function returns nil or false. If this is the case, dialog will just skip to the next line(s) until it finds a valid line or dialog is finished
            func = [function]           : Evaluated after this line has been displayed. Overwritten bei options.option func
            target = [number]           : Line number to jump to after this line is finished. If the target is -1, the dialog will end
            think = [boolean]           : If set, the bubble will be drawn in the style of a thought bubble
            options = [table]           : A table with a set of options  for the player to select, an option has the form {target=[number],text*=[string],func=[function]}, the func is only executed if+after the option has been selected. Note that this overrides the line function (if any)
          }
--]]--
lines[1] = { name = "Daphne", text = function() return "This is a dialog line" end }
lines[2] = { text = function() return "This is another dialog line" end }
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

-- handles log interaction
-- error, debug, verbose

log = {}

local level = "verbose"

function log:init()
    
end

function log:msg(lvl, ...)
    if not ((lvl == "verbose" and (level == "debug" or level == "error")) or
        (lvl == "debug" and level == "error"))then
        local output = ""
        for i = 1, select("#", ...) do
            output = output .. tostring(select(i,...)) .. " "
        end
        print(lvl, output)
    end
end

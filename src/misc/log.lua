-- handles log interaction
-- error, debug, verbose

log = {}

local level = "verbose"

function log:init()
    
end

function log:msg(lvl, msg)
    if not ((lvl == "verbose" and (level == "debug" or level == "error")) or
        (lvl == "debug" and level == "error"))then
        print(lvl, msg)
    end
end

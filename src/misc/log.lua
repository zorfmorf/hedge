 -- handles log interaction
-- error, debug, verbose

log = {}


local cache = {}

local level = "verbose"


function log:init()
    if not C_DEBUG then level = "error" end
end


function log:msg(lvl, ...)
    if not ((lvl == "verbose" and (level == "debug" or level == "error")) or
        (lvl == "debug" and level == "error"))then
        local output = ""
        for i = 1, select("#", ...) do
            output = output .. tostring(select(i,...)) .. " "
        end
        print(lvl, output)
        table.insert(cache, output)
    end
end


function log:save()
    local file = love.filesystem.newFile("log.txt")
    if file then
        file:open("w")
        for i,line in ipairs(cache) do
            file:write(line.."\n")
        end
        file:close()
    else
        print("Error creating output logfile")
    end
end


function love.quit()
    log:save()
    return true
end

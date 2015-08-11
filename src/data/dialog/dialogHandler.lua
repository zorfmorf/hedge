
dialogHandler = {}

local dialogs = nil

function dialogHandler.load()
    dialogs = {}
    
    local dir = "dialog/all/"
    local files = love.filesystem.getDirectoryItems(dir)

    for k, ents in ipairs(files) do
        local name = string.gsub( ents, ".lua", "")
        local data = require(dir .. "/" .. name)
        if type(data) == "table" then
            log:msg("verbose", "Reading dialog:", name)
            dialogs[name] = Dialog(data)
        else
            log:msg("error", "Loading dialog error:", name)
        end
    end
end


function dialogHandler.get(index)
    return dialogs[index]
end

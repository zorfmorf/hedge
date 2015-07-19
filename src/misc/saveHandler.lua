-- handles ingame saving and loading

saveHandler = {}


-- low level method to copy files from to
local function copyFiles(from, to)
    local ok = love.filesystem.createDirectory( to )
    if not ok then log:msg("verbose", "Error creating folder", to) end
    local files = love.filesystem.getDirectoryItems( from )
    log:msg("verbose", "Copying", table.getn(files), "files from", from, "to", to)
    for i,item in ipairs(files) do
        if love.filesystem.isFile(from..item) then
            local file = love.filesystem.newFile(from..item)
            file:open("r")
            local data = file:read()
            file:close()
            file = love.filesystem.newFile(to..item)
            file:open("w")
            file:write(data)
            file:close()
        end
    end
end


-- copy master to current
function saveHandler.newGame()
    copyFiles(C_MAP_MASTER, C_MAP_CURRENT)
end

-- TODO handle different savespots

-- save current game
function saveHandler.saveGame()
    maploader:save(game.map, C_MAP_CURRENT)
    copyFiles(C_MAP_CURRENT, C_MAP_SAVEGAMES..'001/')
end


-- load a game
function saveHandler.loadGame()
    copyFiles(C_MAP_SAVEGAMES..'001/', C_MAP_CURRENT)
    maploader:read(C_MAP_CURRENT, C_MAP_NAME_DEFAULT)
end

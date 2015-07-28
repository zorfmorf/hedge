-- handles ingame saving and loading

saveHandler = {}


-- try to delete folder at target path
local function deleteFolderContents(path)
    if love.filesystem.isFile(path) then 
        log:msg("error", "Tried to delete folder that is a file:", path)
        return
    end
    
    local files = love.filesystem.getDirectoryItems(path)
    for i,filename in ipairs(files) do
        local dir = love.filesystem.getRealDirectory(path..filename)
        os.remove(dir.."/"..path..filename)
    end
end


-- low level method to copy files from to
local function copyFiles(from, to)
    local ok = love.filesystem.createDirectory( to )
    if not ok then log:msg("verbose", "Error creating folder", to) end

    -- gets all files in subdirectory from of both game.zip and save dir!
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
    deleteFolderContents(C_MAP_CURRENT)
    copyFiles(C_MAP_MASTER, C_MAP_CURRENT)
    var.new()
end

-- TODO handle different savespots

-- save current game
function saveHandler.saveGame()
    maploader:save(game.map, C_MAP_CURRENT)
    entityHandler.save()
    var.save()
    copyFiles(C_MAP_CURRENT, C_MAP_SAVEGAMES..'001/')
end


-- load a game
function saveHandler.loadGame()
    deleteFolderContents(C_MAP_CURRENT)
    copyFiles(C_MAP_SAVEGAMES..'001/', C_MAP_CURRENT)
    entityHandler.load()
    var.load()
end

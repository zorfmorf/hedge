-- Set of variables used by events to keep track of things

local vars = {}

var = {}


function var.new()
    vars = {}
end


function var.load()
    vars = {}
    local path = C_MAP_CURRENT .. C_MAP_VAR
    if love.filesystem.isFile( path ) then
        local file = love.filesystem.newFile( path )
        file:open( "r" )
        for line in file:lines() do
            local v = line:split(";")
            vars[v[1]] = v[2]
        end
    end
end


function var.save()
    local path = C_MAP_CURRENT .. C_MAP_VAR
    local file = love.filesystem.newFile( path )
    local result, err = file:open( "w" )
    if result then
        local i = 0
        for key,value in pairs(vars) do
            i = i + 1
            file:write( key..";"..value.."\n" )
        end
        file:close()
        log:msg("verbose", "Wrote", i, "vars to", path)
    else
        log:msg("error", "Error saving vars to ", path, ":", err)
    end
end


function var.get(key)
    local value = vars[key]
    if value then
        if tonumber(value) then return tonumber(value) end
        return value
    end
    return nil
end


function var.set(key, value)
    vars[key] = value
end

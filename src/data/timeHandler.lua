
timeHandler = {}

local year = nil -- 12m
local month = nil -- 30d
local day = nil -- 24h
local hour = nil -- 60m
local minute = nil


function timeHandler.tostr()
    return "Year "..year..", Month "..month..", Day "..day..", "..hour..":"..minute
end


function timeHandler.load()
    year = var.get("year")
    month = var.get("month")
    day = var.get("day")
    hour = var.get("hour")
    minute = var.get("minute")
    if not year then year = 1 end
    if not month then month = 6 end
    if not day then day = 1 end
    if not hour then hour = 8 end
    if not minute then minute = 1 end
    log:msg("verbose", "Initiated timeHandler.", year, month, day, hour)
end


function timeHandler.addTime(minutes)
    minute = minute + minutes
    while minute > 59 do
        minute = minute - 60
        hour = hour + 1
        if hour > 23 then
            hour = 0
            day = day + 1
        end
    end
end


-- returns time and hours as a factor for light multiplication
function timeHandler.getTimeFactor()
    local time = hour
    time = time + minute / 60
    return time
end


function timeHandler.update(dt)
    
end


function timeHandler.advanceDay(value)
    day = day + value
    if day > 30 then
        month = month + 1
        day = day - 30
        if month > 12 then
            year = year + 1
            month = 1
        end
    end
end


function timeHandler.sleep()
    if hour >= 8 then 
        timeHandler.advanceDay(1)
    end
    minute = 1
    hour = 8
end


function timeHandler.transition()
    timeHandler.addTime(60)
end


function timeHandler.action()
    timeHandler.addTime(10)
end


function timeHandler.save()
    var.set("year", year)
    var.set("month", month)
    var.set("day", day)
    var.set("hour", hour)
    var.set("minute", minute)
end

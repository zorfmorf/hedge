
local lines = {}

local function moveBackPlayer()
    player:move("up")
    player.dir = "up"
    player.walking = true
    moveHandler.update(player, 0.0)
end


--  displayed on game start
lines[1] = { text = function() return "I finally arrived!" end }
-- TODO add camera zoom here?
lines[2] = { text = function() return "Although that doesn't look very promising. More of a rundown shack than a farmhouse." end }
lines[3] = { text = function() return "I hope this jorney hasn't been for nothing." end }
lines[4] = { text = function() return "Well..." end }
lines[5] = { text = function() return "I guess only one way to find out." end }


--  displayed once the home is entered
lines[7] = { text = function() return "What a dump ..." end }
lines[8] = { text = function() return "Grandfathers claims of his wealth ... " end }
lines[9] = { text = function() return "ALL LIES!" end }
lines[10] = { text = function() return "..." end }
lines[11] = { text = function() return "To think I left home for this" end }
lines[12] = { text = function() return "I better check if there is anything valuable" end }

lines[55] = { text = function() return "I have not a single piece of gold left. Maybe I can find a job in town?" end, func = function() var.set("tutorial", 6) end }
lines[66] = { text = function() return "It's too late to go into town. I really need to sleep." end, func = moveBackPlayer }
lines[88] = { text = function() return "Nothing here as well " end, func = moveBackPlayer }
lines[77] = { text = function() return "Nothing valuable here ... " end, func = moveBackPlayer } 

-- line to display if the player tries to leave farm map without completing tutorial
lines[99] = { text = function() return "It's too late to go into town, I better take a look around the hut." end, func = moveBackPlayer }

return lines

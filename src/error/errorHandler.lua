

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end


function love.errhand(msg)
	msg = tostring(msg)
 
	error_printer(msg, 2)
 
	if not love.window or not love.graphics or not love.event then
		return
	end
 
	if not love.graphics.isCreated() or not love.window.isCreated() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end
 
	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local font = love.graphics.setNewFont(math.floor(love.window.toPixels(14)))
 
	local sRGB = select(3, love.window.getMode()).srgb
	if sRGB and love.math then
		love.graphics.setBackgroundColor(love.math.gammaToLinear(195, 62, 63))
	else
		love.graphics.setBackgroundColor(195, 62, 63)
	end
 
	love.graphics.setColor(255, 255, 255, 255)
 
	local trace = debug.traceback()
 
	love.graphics.clear()
	love.graphics.origin()
    
    local font2 = love.graphics.setNewFont(love.window.toPixels(50))
 
	local err = {}
 
	table.insert(err, "Woops. Something wrent wrong. Really wrong.\n")
    table.insert(err, "Please send me a description of what you were doing when this crash happened and include either screenshot of this screen or the crashdump located in:\n")
    table.insert(err, "    Linux: ~/.local/share/love/hedge/\n")
    table.insert(err, "    Windows: {home folder}/Application Data/love/hedge/\n")
	table.insert(err, msg.."\n\n")
 
	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end
 
	local p = table.concat(err, "\n")
 
	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")
 
	local function draw()
		local pos = love.window.toPixels(70)
		love.graphics.clear()
        love.graphics.setFont(font2)
        love.graphics.print(":(", pos, pos)
        local buffer = love.graphics.getFont():getHeight() + pos
        love.graphics.setFont(font)
		love.graphics.printf(p, pos + 10, pos + buffer + 10, love.graphics.getWidth() - pos * 4 - 10)
		love.graphics.present()
	end
 
	while true do
		love.event.pump()
 
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			end
			if e == "keypressed" and a == "escape" then
				return
			end
		end
 
		draw()
 
		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end

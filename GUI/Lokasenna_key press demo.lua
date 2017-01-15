
local name, x, y, w, h = "Keypress demo", 200, 200, 250, 100

-- ASCII code for the letter D
local D = 100

-- Declare our variables beforehand so that they aren't flushed when the script loops
local char, char_D, down_time


local function Main()

	-- See if the user pressed Escape (27) or closed the window (-1) to quit
	char = gfx.getchar()
	if char == 27 or char == -1 then
		return 0
		else
		reaper.defer(Main)
	end

	-- If we want to know a specific key's state, we need to specifically ask for that key
	char_D = gfx.getchar(D)


	-- Is the key pressed and it wasn't pressed already?
	if char_D ~= 0 and not down_time then
		
		-- If yes, note the time
		down_time = reaper.time_precise()

	elseif char_D == 0 and down_time then
	
		-- Otherwise, make sure our time stamp is cleared
		down_time = nil
		
	end

	gfx.x, gfx.y = 50, 25
	gfx.drawstr("'D' pressed: "..(tostring(char_D == 1)))

	-- Is the key pressed?
	if down_time then
		
		-- How long has it been pressed?
		local len = reaper.time_precise() - down_time
		
		-- We don't need that many decimal places; let's round it
		-- (multiplying and dividing by 10 = 1 decimal, by 100 = 2 decimals, etc)
		len = math.floor(len * 100) / 100
		gfx.x, gfx.y = 50, 50
		gfx.drawstr(len)
		
		if len > 1 then
			gfx.x, gfx.y = 50, 75
			gfx.drawstr("held")
		end
		
	end
	
	gfx.update()
	
end

gfx.init(name, w, h, 0, x, y)
Main()
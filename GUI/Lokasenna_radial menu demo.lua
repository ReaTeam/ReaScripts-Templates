--[[
	Demonstrates how to implement and display a pop-up radial menu,
	similar to what a lot of first-person shooters use to select weapons, etc.
	
	- Bind the script to a key
	- Hold the key down, a window will open
	- Use the mouse to choose menu options
	- Let the key off, the window will close
	
	
]]--


local name, w, h = "Radial menu demo", 258, 258
local x, y = reaper.GetMousePosition()
x, y = x - (w / 2) - 8, y - (h / 2) - 30

-- Global button dimensions
local r_in, r_out = 64, (w - 2) / 2
local ox, oy = w / 2, h / 2

-- We don't need a ton of precision
local pi = 3.1415927


local mnu_arr = {"file", "edit", "view", "insert", "item", "track", "options", "actions", "ext'ns", "help"}

-- Get the width of each menu option in radians (not worrying about pi yet)
local mnu_adj = 2 / #mnu_arr


local mouse_x, mouse_y, mouse_mnu, key_down
local startup = true

local function Msg(str)
	reaper.ShowConsoleMsg(str.."\n")
end


-- You give it x/y coords and an origin, it returns a polar angle and radius
local function cart2polar(x, y, ox, oy)
	
	local dx, dy = x - ox, y - oy
	
	local angle = math.atan(dy, dx) / pi
	local r = dy / (math.sin(angle * pi)) 

	return angle, r
	
end

-- And vice versa; angle (in rads) and radius --> x/y coords
-- Don't include pi in the angle you give; i.e. 2*pi rads = '2'
local function polar2cart(angle, radius, ox, oy)
	
	local angle = angle * pi
	local x = radius * math.cos(angle)
	local y = radius * math.sin(angle)

	
	if ox and oy then x, y = x + ox, y + oy end

	return x, y
	
end


-- Draw all of the menu options as segments of a ring
local function draw_mnu()

	for i = 0, (#mnu_arr - 1) do
		
		gfx.set(0.2, 1, 0.2, 1)

		-- i * mnu_adj gives us the center of each option; use that get either side of the button
		local angle_a, angle_b = (i - 0.45) * mnu_adj, (i + 0.45) * mnu_adj

		local ax1, ay1 = polar2cart(angle_a, r_in, ox, oy)
		local ax2, ay2 = polar2cart(angle_a, r_out, ox, oy)
		local bx1, by1 = polar2cart(angle_b, r_in, ox, oy)
		local bx2, by2 = polar2cart(angle_b, r_out, ox, oy)
		gfx.line(ax1, ay1, ax2, ay2, 1)
		gfx.line(bx1, by1, bx2, by2, 1)

		-- I'm not sure why the + 0.5 is necessary, but it is
		angle_a = (angle_a + 0.5) * pi
		angle_b = (angle_b + 0.5) * pi
		gfx.arc(ox, oy, r_in, angle_a, angle_b, 1)
		gfx.arc(ox, oy, r_out, angle_a, angle_b, 1)
		
	
		-- Change the background and text colors for the highlighted option
		-- and turn it red if the mouse is clicked
		if i == mouse_mnu then
			
			if mouse_down then gfx.set(1, 0.2, 0.2, 1) end
			
			for j = r_in, r_out, 0.3 do
				gfx.arc(ox, oy, j, angle_a, angle_b, 1)
				--gfx.arc(ox, oy, j, angle_a, angle_b, 0)
			end
			
			if mouse_down then gfx.set(0.2, 1, 0.2, 1) end
		
			gfx.set(0, 0, 0, 1)
		
		else
		
			gfx.set(0.2, 1, 0.2, 1)
		end
		

		-- Center the current option's text in the button
		local str = mnu_arr[i + 1]
		local str_w, str_h = gfx.measurestr(str)
		local cx, cy = polar2cart(i * mnu_adj, r_in + (r_out - r_in) / 2, ox, oy)
		gfx.x, gfx.y = cx - str_w / 2, cy - str_h / 2
		gfx.drawstr(str)

	end	
end



local function Main()

		
	mouse_x, mouse_y = gfx.mouse_x, gfx.mouse_y
	mouse_down = gfx.mouse_cap&1==1
	
	--[[
		'startup' is used as a bit of a cheat, to keep the window open
		until the script is able to detect the key that was held down
		
		'key_down' figures out what key was held ('hold_char'), and then 
		watches to see if it's been released
		
		'up_time' is used to see if the key was let off before the script
		managed to start up, since that would leave the window open rather
		than closing it
	]]--
	if startup then
		key_down = gfx.getchar()
		
		if key_down ~= 0 then
			hold_char = key_down 
			startup = false
		elseif not up_time then
			up_time = reaper.time_precise()
		end
		
	else
		key_down = gfx.getchar(hold_char)
		
	end

	-- Where is the mouse in relation to the center of the window?
	local mouse_angle, mouse_r = cart2polar(mouse_x, mouse_y, ox, oy)
	
	-- Figure out what option the mouse is over
	mouse_mnu = math.floor(mouse_angle / mnu_adj + 0.5)
	if mouse_mnu < 0 then mouse_mnu = mouse_mnu + #mnu_arr end
	if mouse_r < 32 then mouse_mnu = -1 end

	-- Draw all of the options
	draw_mnu()	

	local diff = up_time and (reaper.time_precise() - up_time) or 0
	
--[[
	If 'up_time' manages to run longer than 0.6s, we'll close the script
	(0.6s is the shortest I could set it on my system without the window
	closing and then opening again when Windows says "this key is still
	being held down"
	
	Otherwise, we keep going until the user lets go of the key
]]--	  

	if key_down ~= 0 or (startup and diff < 0.6) then
		reaper.defer(Main)
	else
		return 0
	end
	
	gfx.update()
	
end





gfx.init(name, w, h, 0, x, y)
Main()
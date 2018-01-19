----------------------------------------------------------------
------------------Copy everything from here---------------------
----------------------------------------------------------------

local function GUI_table ()

local GUI = {}

GUI.version = "1.0"


-- Print stuff to the Reaper console. For debugging purposes.
GUI.Msg = function (str)
	reaper.ShowConsoleMsg(tostring(str).."\n")
end


--[[	Use when working with file paths if you need to add your own /s
		(Borrowed from X-Raym)	
]]--
GUI.file_sep = string.match(reaper.GetOS(), "Win") and "\\" or "/"


--Also might need to know this
GUI.SWS_exists = reaper.APIExists("BR_Win32_GetPrivateProfileString")




	---- Keyboard constants ----
	
GUI.chars = {
	
	ESCAPE		= 27,
	SPACE		= 32,
	BACKSPACE	= 8,
	HOME		= 1752132965,
	END			= 6647396,
	INSERT		= 6909555,
	DELETE		= 6579564,
	RETURN		= 13,
	UP			= 30064,
	DOWN		= 1685026670,
	LEFT		= 1818584692,
	RIGHT		= 1919379572,
	
	F1			= 26161,
	F2			= 26162,
	F3			= 26163,
	F4			= 26164,
	F5			= 26165,
	F6			= 26166,
	F7			= 26167,
	F8			= 26168,
	F9			= 26169,
	F10			= 6697264,
	F11			= 6697265,
	F12			= 6697266

}


--[[	Font and color presets
	
	Can be set using the accompanying functions GUI.font
	and GUI.color. i.e.
	
	GUI.font(2)				applies the Header preset
	GUI.color("elm_fill")	applies the Element Fill color preset
	
	Colors are converted from 0-255 to 0-1 when GUI.Init() runs,
	so if you need to access the values directly at any point be
	aware of which format you're getting in return.
		
]]--
GUI.fonts = {
	
				-- Font, size, bold/italics/underline
				-- 				^ One string: "b", "iu", etc.
				{"Calibri", 32},	-- 1. Title
				{"Calibri", 20},	-- 2. Header
				{"Calibri", 16},	-- 3. Label
				{"Calibri", 16},	-- 4. Value
	version = 	{"Calibri", 12, "i"},
	
}


GUI.colors = {
	
	-- Element colors
	wnd_bg = {64, 64, 64, 255},			-- Window BG
	tab_bg = {56, 56, 56, 255},			-- Tabs BG
	elm_bg = {48, 48, 48, 255},			-- Element BG
	elm_frame = {96, 96, 96, 255},		-- Element Frame
	elm_fill = {64, 192, 64, 255},		-- Element Fill
	elm_outline = {32, 32, 32, 255},	-- Element Outline
	txt = {192, 192, 192, 255},			-- Text
	
	shadow = {0, 0, 0, 48},				-- Element Shadows
	faded = {0, 0, 0, 64},
	
	-- Standard 16 colors
	black = {0, 0, 0, 255},
	white = {255, 255, 255, 255},
	red = {255, 0, 0, 255},
	lime = {0, 255, 0, 255},
	blue =  {0, 0, 255, 255},
	yellow = {255, 255, 0, 255},
	cyan = {0, 255, 255, 255},
	magenta = {255, 0, 255, 255},
	silver = {192, 192, 192, 255},
	gray = {128, 128, 128, 255},
	maroon = {128, 0, 0, 255},
	olive = {128, 128, 0, 255},
	green = {0, 128, 0, 255},
	purple = {128, 0, 128, 255},
	teal = {0, 128, 128, 255},
	navy = {0, 0, 128, 255},
	
	none = {0, 0, 0, 0},
	

}


--[[	Apply a font preset
	
	fnt			Font preset number
				or
				A preset table -> GUI.font({"Arial", 10, "i"})
	
]]--
GUI.font = function (fnt)
	
	local font, size, str = table.unpack( type(fnt) == "table" and fnt or GUI.fonts[fnt])
	
	-- Different OSes use different font sizes, for some reason
	-- This should give a roughly equal size on Mac
	if string.find(reaper.GetOS(), "OSX") then
		size = math.floor(size * 0.8)
	end
	
	-- Cheers to Justin and Schwa for this
	local flags = 0
	if str then
		for i = 1, str:len() do 
			flags = flags * 256 + string.byte(str, i) 
		end 	
	end
	
	gfx.setfont(1, font, size, flags)

end


--[[	Apply a color preset
	
	col			Color preset string -> "elm_fill"
				or
				Color table -> {1, 0.5, 0.5[, 1]}
								R  G    B  [  A]
]]--			
GUI.color = function (col)

	-- If we're given a table of color values, just pass it right along
	if type(col) == "table" then

		gfx.set(col[1], col[2], col[3], col[4] or 1)
	else
		gfx.set(table.unpack(GUI.colors[col]))
	end	

end



-- Global shadow size, in pixels
GUI.shadow_dist = 2

--[[
	How fast the caret in textboxes should blink, measured in GUI update loops.
	
	'16' looks like a fairly typical textbox caret.
	
	Because each On and Off redraws the textbox's Z layer, this can cause CPU issues
	in scripts with lots of drawing to do. In that case, raising it to 24 or 32
	will still look alright but require less redrawing.
]]--
GUI.txt_blink_rate = 16


-- Draw the given string of the first color with a shadow 
-- of the second color (at 45' to the bottom-right)
GUI.shadow = function (str, col1, col2)
	
	local x, y = gfx.x, gfx.y
	
	GUI.color(col2)
	for i = 1, GUI.shadow_dist do
		gfx.x, gfx.y = x + i, y + i
		gfx.drawstr(str)
	end
	
	GUI.color(col1)
	gfx.x, gfx.y = x, y
	gfx.drawstr(str)
	
end


-- Draws a string using the given text and outline color presets
GUI.outline = function (str, col1, col2)

	local x, y = gfx.x, gfx.y
	
	GUI.color(col2)
	
	gfx.x, gfx.y = x + 1, y + 1
	gfx.drawstr(str)
	gfx.x, gfx.y = x - 1, y + 1
	gfx.drawstr(str)
	gfx.x, gfx.y = x - 1, y - 1
	gfx.drawstr(str)
	gfx.x, gfx.y = x + 1, y - 1
	gfx.drawstr(str)
	
	GUI.color(col1)
	gfx.x, gfx.y = x, y
	gfx.drawstr(str)
	
end


--[[	Draw a background rectangle for the given string
	
	A solid background is necessary for blitting z layers
	on their own; antialiased text with a transparent background
	looks like complete shit. This function draws a rectangle 2px
	larger than your text on all sides.
	
	Call with your position, font, and color already set:
	
	gfx.x, gfx.y = self.x, self.y
	GUI.font(self.font)
	GUI.color(self.col)
	
	GUI.text_bg(self.text)
	
	gfx.drawstr(self.text)
	
	Also accepts an optional background color:
	GUI.text_bg(self.text, "elm_bg")
	
]]--
GUI.text_bg = function (str, col)
	
	local x, y = gfx.x, gfx.y
	local r, g, b, a = gfx.r, gfx.g, gfx.b, gfx.a
	
	col = col or "wnd_bg"
	
	GUI.color(col)
	
	local w, h = gfx.measurestr(str)
	w, h = w + 4, h + 4
		
	gfx.rect(gfx.x - 2, gfx.y - 2, w, h, true)
	
	gfx.x, gfx.y = x, y
	
	gfx.set(r, g, b, a)	
	
end



	---- General functions ----
		



--[[
	Copy the contents of one table to another, since Lua can't do it natively
	
	Provide a second table as 'base' to use it as the basis for copying, only
	bringing over keys from the source table that don't exist in the base
	
	'depth' only exists to provide indenting for my debug messages, it can
	be left out when calling the function.
]]--
GUI.table_copy = function (source, base, depth)
	
	-- 'Depth' is only for indenting debug messages
	depth = ((not not depth) and (depth + 1)) or 0
	
	
	
	if type(source) ~= "table" then return source end
	
	local meta = getmetatable(source)
	local new = base or {}
	for k, v in pairs(source) do
		

		
		if type(v) == "table" then
			
			--_=dm and GUI.Msg(string.rep("\t", depth + 1)..tostring(k).." is a table; recursing...")
			
			if base then
				--_=dm and GUI.Msg(string.rep("\t", depth).."base:\t"..tostring(k))
				new[k] = GUI.table_copy(v, base[k], depth)
			else
				new[k] = GUI.table_copy(v, nil, depth)
			end
			
		else
			if not base or (base and new[k] == nil) then 
				--_=dm and GUI.Msg(string.rep("\t", depth).."added:\t"..tostring(k).." = "..tostring(v))		
				new[k] = v
			end
		end
		
		--_=dm and GUI.Msg(string.rep("\t", depth).."done with "..tostring(k))
	end
	setmetatable(new, meta)
	
	--_=dm and GUI.Msg(string.rep("\t", depth).."finished copying")
	
	return new
	
end



-- Compare the contents of one table to another, since Lua can't do it natively
GUI.table_compare = function (t_a, t_b)
	
	if type(t_a) ~= "table" or type(t_b) ~= "table" then return false end
	
	local key_exists = {}
	for k1, v1 in pairs(t_a) do
		local v2 = t_b[k1]
		if v2 == nil or not GUI.table_compare(v1, v2) then return false end
		key_exists[k1] = true
	end
	for k2, v2 in pairs(t_b) do
		if not key_exists[k2] then return false end
	end
	
end
		
		

-- To open files in their default app, or URLs in a browser
-- Copied from Heda; cheers!
GUI.open_file = function (path)

	local OS = reaper.GetOS()

    if OS == "OSX32" or OS == "OSX64" then
		os.execute('open "" "' .. path .. '"')
	else
		os.execute('start "" "' .. path .. '"')
	end
  
end



-- 	Sorting function adapted from: http://lua-users.org/wiki/SortedIteration
GUI.full_sort = function (op1, op2)

	-- Sort strings that begin with a number as if they were numbers,
	-- i.e. so that 12 > "6 apples"
	if type(op1) == "string" and string.match(op1, "^(%-?%d+)") then
		op1 = tonumber( string.match(op1, "^(%-?%d+)") )
	end
	if type(op2) == "string" and string.match(op2, "^(%-?%d+)") then
		op2 = tonumber( string.match(op2, "^(%-?%d+)") )
	end

	--if op1 == "0" then op1 = 0 end
	--if op2 == "0" then op2 = 0 end
	local type1, type2 = type(op1), type(op2)
	if type1 ~= type2 then --cmp by type
		return type1 < type2
	elseif type1 == "number" and type2 == "number"
		or type1 == "string" and type2 == "string" then
		return op1 < op2 --comp by default
	elseif type1 == "boolean" and type2 == "boolean" then
		return op1 == true
	else
		return tostring(op1) < tostring(op2) --cmp by address
	end
	
end

--[[
	Allows "for x, y in pairs(z) do" in alphabetical/numerical order
	Copied from Programming In Lua, 19.3
	
	Call with f = "full" to use the full sorting function above, or
	use f to provide your own sorting function as per pairs() and ipairs()
	
]]--
GUI.kpairs = function (t, f)


	if f == "full" then
		f = GUI.full_sort
	end

	local a = {}
	for n in pairs(t) do table.insert(a, n) end

	table.sort(a, f)
	
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
	
		i = i + 1
		
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
		
	end
	
	
	return iter
end




	---- Text functions ----


--[[	Prepares a table of character widths
	
	Iterates through all of the GUI.fonts[] presets, storing the widths
	of every printable ASCII character in a table. 
	
	Accessable via:		GUI.txt_width[font_num][char_num]
	
	- Requires a window to have been opened in Reaper
	
	- 'get_txt_width' and 'word_wrap' will automatically run this
	  if it hasn't been run already; it may be rather clunky to use
	  on demand depending on what your script is doing, so it's
	  probably better to run this immediately after initiliazing
	  the window and then have the width table ready to use.
]]--

GUI.init_txt_width = function ()

	_=dm and GUI.Msg("init_txt_width")

	GUI.txt_width = {}
	local arr
	for k in pairs(GUI.fonts) do
			
		GUI.font(k)
		GUI.txt_width[k] = {}
		arr = {}
		
		for i = 1, 255 do
			
			arr[i] = gfx.measurechar(i)
			
		end	
		
		GUI.txt_width[k] = arr
		
	end
	
end


-- Returns the total width (in pixels) for a given string and font
GUI.get_txt_width = function (str, font)
	
	if not GUI.txt_width then GUI.init_txt_width() end 

	local widths = GUI.txt_width[font]
	local w = 0
	for i = 1, string.len(str) do

		w = w + widths[		string.byte(	string.sub(str, i, i)	) ]

	end

	return w

end


--[[	Returns 'str' wrapped to fit a given pixel width
	
	str		String. Can include line breaks/paragraphs; they should be preserved.
	font	Font preset number
	w		Pixel width
	indent	Number of spaces to indent the first line of each paragraph
			(The algorithm skips tab characters and leading spaces, so
			use this parameter instead)
	
	i.e.	Blah blah blah blah		-> indent = 2 ->	  Blah blah blah blah
			blah blah blah blah							blah blah blah blah

	
	pad		Indent wrapped lines by the first __ characters of the paragraph
			(For use with bullet points, etc)
			
	i.e.	- Blah blah blah blah	-> pad = 2 ->	- Blah blah blah blah
			blah blah blah blah				  	 	  blah blah blah blah
	
				
	This function expands on the "greedy" algorithm found here:
	https://en.wikipedia.org/wiki/Line_wrap_and_word_wrap#Algorithm
				
]]--
GUI.word_wrap = function (str, font, w, indent, pad)
	
	_=dm and GUI.Msg("word wrap:\n\tfont "..tostring(font).."\n\twidth "..tostring(w).."\n\tindent "..tostring(indent))
	
	if not GUI.txt_width then GUI.init_txt_width() end
	
	local ret_str = {}

	local w_left, w_word
	local space = GUI.txt_width[font][string.byte(" ")]
	
	local new_para = indent and string.rep(" ", indent) or 0
	
	local w_pad = pad and GUI.get_txt_width(	string.sub(str, 1, pad), font	) or 0
	local new_line = "\n"..string.rep(" ", math.floor(w_pad / space)	)
	
	
	for line in string.gmatch(str, "([^\n\r]*)[\n\r]*") do
		
		table.insert(ret_str, new_para)
		
		-- Check for leading spaces and tabs
		local leading, line = string.match(line, "^([%s\t]*)(.*)$")	
		if leading then table.insert(ret_str, leading) end
		
		w_left = w
		for word in string.gmatch(line,  "([^%s]+)") do
	
			w_word = GUI.get_txt_width(word, font)
			if (w_word + space) > w_left then
				
				table.insert(ret_str, new_line)
				w_left = w - w_word
				
			else
			
				w_left = w_left - (w_word + space)
				
			end
			
			table.insert(ret_str, word)
			table.insert(ret_str, " ")
			
		end
		
		table.insert(ret_str, "\n")
		
	end
	
	table.remove(ret_str, #ret_str)
	ret_str = table.concat(ret_str)
	
	return ret_str
			
end



-- Returns an ordinal string (i.e. 30 --> 30th)
GUI.ordinal = function (num)
	
	rem = num % 10
	num = GUI.round(num)
	if num == 1 then
		str = num.."st"
	elseif rem == 2 then
		str = num.."nd"
	elseif num == 13 then
		str = num.."th"
	elseif rem == 3 then
		str = num.."rd"
	else
		str = num.."th"
	end
	
	return str
	
end



	---- Color and drawing functions ----


-- Convert a hex color RRGGBB to 8-bit values R, G, B
GUI.hex2rgb = function (num)
	
	if string.sub(num, 1, 2) == "0x" then
		num = string.sub(num, 3)
	end

	local red = string.sub(num, 1, 2)
	local green = string.sub(num, 3, 4)
	local blue = string.sub(num, 5, 6)

	
	red = tonumber(red, 16) or 0
	green = tonumber(green, 16) or 0
	blue = tonumber(blue, 16) or 0

	return red, green, blue
	
end


-- Convert rgb[a] to hsv[a]; useful for gradients
-- Arguments/returns are given as 0-1
GUI.rgb2hsv = function (r, g, b, a)
	
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local chroma = max - min
	
	-- Dividing by zero is never a good idea
	if chroma == 0 then
		return 0, 0, max, (a or 1)
	end
	
	local hue
	if max == r then
		hue = ((g - b) / chroma) % 6
	elseif max == g then
		hue = ((b - r) / chroma) + 2
	elseif max == b then
		hue = ((r - g) / chroma) + 4
	else
		hue = -1
	end
	
	if hue ~= -1 then hue = hue / 6 end
	
	local sat = (max ~= 0) 	and	((max - min) / max)
							or	0
							
	return hue, sat, max, (a or 1)
	
	
end

-- ...and back the other way
GUI.hsv2rgb = function (h, s, v, a)
	
	local chroma = v * s
	
	local hp = h * 6
	local x = chroma * (1 - math.abs(hp % 2 - 1))
	
	local r, g, b
	if hp <= 1 then
		r, g, b = chroma, x, 0
	elseif hp <= 2 then
		r, g, b = x, chroma, 0
	elseif hp <= 3 then
		r, g, b = 0, chroma, x
	elseif hp <= 4 then
		r, g, b = 0, x, chroma
	elseif hp <= 5 then
		r, g, b = x, 0, chroma
	elseif hp <= 6 then
		r, g, b = chroma, 0, x
	else
		r, g, b = 0, 0, 0
	end
	
	local min = v - chroma	
	
	return r + min, g + min, b + min, (a or 1)
	
end


--[[
	Returns the color for a given position on an HSV gradient 
	between two color presets

	col_a		Tables of {R, G, B[, A]}, values from 0-1
	col_b
	
	pos			Position along the gradient, 0 = col_a, 1 = col_b
	
	returns		r, g, b, a

]]--
GUI.gradient = function (col_a, col_b, pos)
	
	local col_a = {GUI.rgb2hsv( table.unpack( type(col_a) == "table" and col_a or GUI.colors(col_a) )) }
	local col_b = {GUI.rgb2hsv( table.unpack( type(col_b) == "table" and col_b or GUI.colors(col_b) )) }
	
	local h = math.abs(col_a[1] + (pos * (col_b[1] - col_a[1])))
	local s = math.abs(col_a[2] + (pos * (col_b[2] - col_a[2])))
	local v = math.abs(col_a[3] + (pos * (col_b[3] - col_a[3])))
	local a = (#col_a == 4) and (math.abs(col_a[4] + (pos * (col_b[4] - col_a[4])))) or 1
	
	return GUI.hsv2rgb(h, s, v, a)
	
end


-- Round a number to the nearest integer (or optional decimal places)
GUI.round = function (num, places)

	if not places then
		return num > 0 and math.floor(num + 0.5) or math.ceil(num - 0.5)
	else
		places = 10^places
		return num > 0 and math.floor(num * places + 0.5) or math.ceil(num * places - 0.5) / places
	end
	
end

-- Make sure val is between min and max
GUI.clamp = function (num, min, max)
	if min > max then min, max = max, min end
	return math.min(math.max(num, min), max)
end


-- Odds are you don't need much precision
-- If you do, just specify GUI.pi = math.pi() in your code
GUI.pi = 3.14159


-- Improved roundrect() function with fill, adapted from mwe's EEL example.
GUI.roundrect = function (x, y, w, h, r, antialias, fill)
	
	local aa = antialias or 1
	fill = fill or 0
	
	if fill == 0 or false then
		gfx.roundrect(x, y, w, h, r, aa)
	else
	
		if h >= 2 * r then
			
			-- Corners
			gfx.circle(x + r, y + r, r, 1, aa)			-- top-left
			gfx.circle(x + w - r, y + r, r, 1, aa)		-- top-right
			gfx.circle(x + w - r, y + h - r, r , 1, aa)	-- bottom-right
			gfx.circle(x + r, y + h - r, r, 1, aa)		-- bottom-left
			
			-- Ends
			gfx.rect(x, y + r, r, h - r * 2)
			gfx.rect(x + w - r, y + r, r + 1, h - r * 2)
				
			-- Body + sides
			gfx.rect(x + r, y, w - r * 2, h + 1)
			
		else
		
			r = (h / 2 - 1)
		
			-- Ends
			gfx.circle(x + r, y + r, r, 1, aa)
			gfx.circle(x + w - r, y + r, r, 1, aa)
			
			-- Body
			gfx.rect(x + r, y, w - (r * 2), h)
			
		end	
		
	end
	
end


-- Improved triangle() function with optional non-fill
GUI.triangle = function (fill, ...)
	
	-- Pass any calls for a filled triangle on to the original function
	if fill == 1 then
		
		gfx.triangle(...)
		
	else
	
		-- Store all of the provided coordinates into an array
		local coords = {...}
		
		-- Duplicate the first pair at the end, so the last line will
		-- be drawn back to the starting point.
		table.insert(coords, coords[1])
		table.insert(coords, coords[2])
	
		-- Draw a line from each pair of coords to the next pair.
		for i = 1, #coords - 2, 2 do			
				
			gfx.line(coords[i], coords[i+1], coords[i+2], coords[i+3])
		
		end		
	
	end
	
end


--[[ 
	Takes an angle in radians (omit Pi) and a radius, returns x, y
	Will return coordinates relative to an origin of (0,0), or absolute
	coordinates if an origin point is specified
]]--
GUI.polar2cart = function (angle, radius, ox, oy)
	
	local angle = angle * GUI.pi
	local x = radius * math.cos(angle)
	local y = radius * math.sin(angle)

	
	if ox and oy then x, y = x + ox, y + oy end

	return x, y
	
end


--[[
	Takes cartesian coords, with optional origin coords, and returns
	an angle (in radians) and radius. The angle is given without reference
	to Pi; that is, pi/4 rads would return as simply 0.25
]]--
GUI.cart2polar = function (x, y, ox, oy)
	
	local dx, dy = x - (ox or 0), y - (oy or 0)
	
	local angle = math.atan(dy, dx) / GUI.pi
	local r = math.sqrt(dx * dx + dy * dy)

	return angle, r
	
end


--[[
	We'll use this to let elements have their own graphics buffers
	to do whatever they want in. 
	
	num	=	How many buffers you want, or 1 if not specified.
	
	Returns a table of buffers, or just a buffer number if num = 1
	
	i.e.
	
	-- Assign this element's buffer
	function GUI.my_element:new(.......)
	
	   ...new stuff...
	   
	   my_element.buffers = GUI.GetBuffer(4)
	   -- or
	   my_element.buffer = GUI.GetBuffer()
		
	end
	
	-- Draw to the buffer
	function GUI.my_element:init()
		
		gfx.dest = self.buffers[1]
		-- or
		gfx.dest = self.buffer
		...draw stuff...
	
	end
	
	-- Copy from the buffer
	function GUI.my_element:draw()
		gfx.blit(self.buffers[1], 1, 0)
		-- or
		gfx.blit(self.buffer, 1, 0)
	end
	
]]--

-- Any used buffers will be marked as True here
GUI.buffers = {}

-- When deleting elements, their buffer numbers
-- will be added here for easy access.
GUI.freed_buffers = {}

GUI.GetBuffer = function (num)
	
	local ret = {}
	local prev
	
	for i = 1, (num or 1) do
		
		if #GUI.freed_buffers > 0 then
			
			ret[i] = table.remove(GUI.freed_buffers)
			
		else
		
			for j = (not prev and 1023 or prev - 1), 0, -1 do
			
				if not GUI.buffers[j] then
					ret[i] = j
					GUI.buffers[j] = true
					break
				end
				
			end
			
		end
		
	end

	return (#ret == 1) and ret[1] or ret

end

-- Elements should pass their buffer (or buffer table) to this
-- when being deleted
GUI.FreeBuffer = function (num)
	
	if type(num) == "number" then
		table.insert(GUI.freed_buffers, num)
	else
		for k, v in pairs(num) do
			table.insert(GUI.freed_buffers, v)
		end
	end	
	
end





-- Are these coordinates inside the given element?
-- If no coords are given, will use the mouse cursor
GUI.IsInside = function (elm, x, y)

	if not elm then return false end

	local x, y = x or GUI.mouse.x, y or GUI.mouse.y

	return	(	x >= (elm.x or 0) and x < ((elm.x or 0) + (elm.w or 0)) and 
				y >= (elm.y or 0) and y < ((elm.y or 0) + (elm.h or 0))	)
	
end



--[[
Returns x,y coordinates for a window with the specified anchor position

If no anchor is specified, it will default to the top-left corner of the screen.
	x,y		offset coordinates from the anchor position
	w,h		window dimensions
	anchor	"screen" or "mouse"
	corner	"TL"
			"T"
			"TR"
			"R"
			"BR"
			"B"
			"BL"
			"L"
			"C"
]]--
GUI.get_window_pos = function (x, y, w, h, anchor, corner)

	local ax, ay, aw, ah = 0, 0, 0 ,0
		
	local __, __, scr_w, scr_h = reaper.my_getViewport(x, y, x + w, y + h, x, y, x + w, y + h, 1)
	
	if anchor == "screen" then
		aw, ah = scr_w, scr_h
	elseif anchor =="mouse" then
		ax, ay = reaper.GetMousePosition()
	end
	
	local cx, cy = 0, 0
	if corner then
		local corners = {
			TL = 	{0, 				0},
			T =		{(aw - w) / 2, 		0},
			TR = 	{(aw - w) - 16,		0},
			R =		{(aw - w) - 16,		(ah - h) / 2},
			BR = 	{(aw - w) - 16,		(ah - h) - 40},
			B =		{(aw - w) / 2, 		(ah - h) - 40},
			BL = 	{0, 				(ah - h) - 40},
			L =	 	{0, 				(ah - h) / 2},
			C =	 	{(aw - w) / 2,		(ah - h) / 2},
		}
		
		cx, cy = table.unpack(corners[corner])
	end	
	
	x = x + ax + cx
	y = y + ay + cy
	
--[[
	
	Disabled until I can figure out the multi-monitor issue
	
	-- Make sure the window is entirely on-screen
	local l, t, r, b = x, y, x + w, y + h
	
	if l < 0 then x = 0 end
	if r > scr_w then x = (scr_w - w - 16) end
	if t < 0 then y = 0 end
	if b > scr_h then y = (scr_h - h - 40) end
]]--	
	
	return x, y	
	
end


-- Display the GUI version number
-- Set GUI.version = 0 to hide this
GUI.Draw_Version = function ()
	
	if not GUI.version then return 0 end

	local str = "Lokasenna_GUI "..GUI.version
	
	GUI.font("version")
	GUI.color("txt")
	
	local str_w, str_h = gfx.measurestr(str)
	
	--gfx.x = GUI.w - str_w - 4
	--gfx.y = GUI.h - str_h - 4
	gfx.x = gfx.w - str_w - 6
	gfx.y = gfx.h - str_h - 4
	
	gfx.drawstr(str)	
	
end





	---- Z-layer blitting ----

-- On each draw loop, only layers that are set to true in this table
-- will be redrawn; if false, it will just copy them from the buffer
-- Set [0] = true to redraw everything.
GUI.redraw_z = {}



	---- Our main functions ----

-- All child elements are stored here
GUI.elms = {}


-- Maintain a list of all GUI elements, sorted by their z order	
-- Also removes any elements with z = -1, for automatically
-- cleaning things up.
GUI.elms_list = {}
GUI.z_max = 0
GUI.update_elms_list = function (init)
	
	local z_table = {}

	for key, __ in pairs(GUI.elms) do

		local z = GUI.elms[key].z or 5

		-- Delete elements if the script asked to
		if z == -1 then
			
			GUI.elms[key]:ondelete()
			GUI.elms[key] = nil
			
		else

			if z_table[z] then
				table.insert(z_table[z], key)

			else
				z_table[z] = {key}

			end
		
		end
		
		if init then 
			
			GUI.elms[key]:init()
			GUI.z_max = math.max(z, GUI.z_max)

		end
	end

	for i = 0, GUI.z_max do
		if not z_table[i] then z_table[i] = {} end
	end

	GUI.elms_list = z_table
	
end

GUI.elms_hide = {}
GUI.elms_freeze = {}






GUI.Init = function ()
	
	
	-- Create the window
	gfx.clear = reaper.ColorToNative(table.unpack(GUI.colors.wnd_bg))
	
	if not GUI.x then GUI.x = 0 end
	if not GUI.y then GUI.y = 0 end
	if not GUI.w then GUI.w = 640 end
	if not GUI.h then GUI.h = 480 end

	if GUI.anchor and GUI.corner then
		GUI.x, GUI.y = GUI.get_window_pos(GUI.x, GUI.y, GUI.w, GUI.h, GUI.anchor, GUI.corner)
	end
		
	gfx.init(GUI.name, GUI.w, GUI.h, GUI.dock or 0, GUI.x, GUI.y)
	
	
	GUI.cur_w, GUI.cur_h = gfx.w, gfx.h

	-- Measure the window's title bar, in case we need it
	local __, __, wnd_y, __, __ = gfx.dock(-1, 0, 0, 0, 0)
	local __, gui_y = gfx.clienttoscreen(0, 0)
	GUI.title_height = gui_y - wnd_y


	-- Initialize a few values
	GUI.last_time = 0
	GUI.mouse = {
	
		x = 0,
		y = 0,
		cap = 0,
		down = false,
		wheel = 0,
		lwheel = 0
		
	}
		
	-- Convert color presets from 0..255 to 0..1
	for i, col in pairs(GUI.colors) do
		col[1], col[2], col[3], col[4] = col[1] / 255, col[2] / 255, col[3] / 255, col[4] / 255
	end
	
	-- Initialize the tables for our z-order functions
	GUI.update_elms_list(true)	
	
	if GUI.Exit then reaper.atexit(GUI.Exit) end
	
	GUI.gfx_open = true

end


GUI.Main = function ()
	
	-- Update mouse and keyboard state, window dimensions
	GUI.mouse.lx, GUI.mouse.ly = GUI.mouse.x, GUI.mouse.y
	GUI.mouse.x, GUI.mouse.y = gfx.mouse_x, gfx.mouse_y
	GUI.mouse.wheel = gfx.mouse_wheel
	GUI.mouse.cap = gfx.mouse_cap
	GUI.char = gfx.getchar() 
	
	if GUI.cur_w ~= gfx.w or GUI.cur_h ~= gfx.h then
		GUI.cur_w, GUI.cur_h = gfx.w, gfx.h
		GUI.resized = true
	else
		GUI.resized = false
	end
	
	--	(Escape key)	(Window closed)		(User function says to close)
	if GUI.char == 27 or GUI.char == -1 or GUI.quit == true then
		return 0
	else
		reaper.defer(GUI.Main)
	end


	--GUI.mouse.down = false
	--GUI.mouse.r_down = false

--[[
	Update each element's state, starting from the top down.
	
	This is very important, so that lower elements don't
	"steal" the mouse.
	
	
	This function will also delete any elements that have their z set to -1

	Handy for something like Label:fade if you just want to remove
	the faded element entirely
	
	***Don't try to remove elements in the middle of the Update
	loop; use this instead to have them automatically cleaned up***	
	
]]--
	GUI.update_elms_list()
	
	-- We'll use this to shorten each elm's update loop if the user did something
	-- Slightly more efficient, and averts any bugs from false positives
	GUI.elm_updated = false

	for i = 0, GUI.z_max do
		if #GUI.elms_list[i] > 0 and not (GUI.elms_hide[i] or GUI.elms_freeze[i]) then
			for __, elm in pairs(GUI.elms_list[i]) do

				if elm then GUI.Update(GUI.elms[elm]) end
				--if GUI.elm_updated then break end
				
			end
		end
		
		--if GUI.elm_updated then break end
		
	end

	-- Just in case any user functions want to know...
	GUI.mouse.last_down = GUI.mouse.down
	GUI.mouse.last_r_down = GUI.mouse.r_down


	-- If the user gave us a function to run, check to see if it needs to be run again, and do so.
	-- 
	if GUI.func then
		
		local new_time = os.time()
		if new_time - GUI.last_time >= (GUI.freq or 1) then
			GUI.func()
			GUI.last_time = new_time
		
		end
	end
	
	-- Redraw all of the elements, starting from the bottom up.
	GUI.update_elms_list()

	--local w, h = gfx.w, gfx.h
	local w, h = GUI.w, GUI.h

	--[[
		Having everything draw to a single buffer is less efficient than having
		separate buffers per Z, but it gets around the problem of text looking shitty
		because it's been anti-aliased with a transparent background.
	]]--

	local need_redraw = false
	if GUI.redraw_z[0] then
		need_redraw = true
	else
		for z, b in pairs(GUI.redraw_z) do
			if b == true then 
				need_redraw = true 
				break
			end
		end
	end

	if need_redraw then
		
		-- All of the layers will be drawn to their own buffer (dest = z), then
		-- composited in buffer 0. This allows buffer 0 to be blitted as a whole
		-- when none of the layers need to be redrawn.
		
		gfx.dest = 0
		gfx.setimgdim(0, -1, -1)
		gfx.setimgdim(0, w, h)

		GUI.color("wnd_bg")
		gfx.rect(0, 0, w, h, 1)

		for i = GUI.z_max, 0, -1 do
			if #GUI.elms_list[i] > 0 and not GUI.elms_hide[i] then
				
				if GUI.redraw_z[i] then
					
					-- Set this before we redraw, so that elms can call a redraw from
					-- their own :draw method. e.g. Labels fading out
					GUI.redraw_z[i] = false

					gfx.setimgdim(i, -1, -1)
					gfx.setimgdim(i, w, h)
					gfx.dest = i
					
					for __, elm in pairs(GUI.elms_list[i]) do
						if not GUI.elms[elm] then GUI.Msg(elm.." doesn't exist?") end
						GUI.elms[elm]:draw()
					end

					gfx.dest = 0
				end
							
				gfx.blit(i, 1, 0, 0, 0, w, h, 0, 0, w, h, 0, 0)
			end
		end
		GUI.Draw_Version()		
		
	end
	gfx.dest = -1
	gfx.blit(0, 1, 0, 0, 0, w, h, 0, 0, w, h, 0, 0)
	
	gfx.update()
	
end


--	See if the any of the given element's methods need to be called
GUI.Update = function (elm)
	
	local x, y = GUI.mouse.x, GUI.mouse.y
	local wheel = GUI.mouse.wheel
	local inside = GUI.IsInside(elm, x, y)
	
	local skip = elm:onupdate() or false
	
	if GUI.elm_updated then
		if elm.focus then
			elm.focus = false
			elm:lostfocus()
		end
		skip = true
	end


	if not skip then
		
		-- Left button
		if GUI.mouse.cap&1==1 then
			
			-- If it wasn't down already...
			if not GUI.mouse.last_down then


				-- Was a different element clicked?
				if not inside then 
					if elm.focus then
						elm.focus = false
						elm:lostfocus()
					end
					return 0
				else	
				
					-- Double clicked?
					if GUI.mouse.downtime and reaper.time_precise() - GUI.mouse.downtime < 0.10 then
	
						GUI.mouse.downtime = nil
						GUI.mouse.dbl_clicked = true
						elm:ondoubleclick()						
						
					elseif not GUI.mouse.dbl_clicked then
				
						elm.focus = true
						elm:onmousedown()						
					
					end
					
					GUI.mouse.down = true
					GUI.mouse.ox, GUI.mouse.oy = x, y
					GUI.elm_updated = true
					
				end
							
			-- 		Dragging? 									Did the mouse start out in this element?
			elseif (x ~= GUI.mouse.lx or y ~= GUI.mouse.ly) and GUI.IsInside(elm, GUI.mouse.ox, GUI.mouse.oy) then
			
				if elm.focus ~= false then 

					GUI.elm_updated = true
					elm:ondrag()
					
				end
			end

		-- If it was originally clicked in this element and has now been released
		elseif GUI.mouse.down and GUI.IsInside(elm, GUI.mouse.ox, GUI.mouse.oy) then
		
			-- We don't want to trigger an extra mouse-up after double clicking
			if not GUI.mouse.dbl_clicked then elm:onmouseup() end
			
			GUI.elm_updated = true
			GUI.mouse.down = false
			GUI.mouse.dbl_clicked = false
			GUI.mouse.ox, GUI.mouse.oy = -1, -1
			GUI.mouse.lx, GUI.mouse.ly = -1, -1
			GUI.mouse.downtime = reaper.time_precise()

		end
		
		
		-- Right button
		if GUI.mouse.cap&2==2 then
			
			-- If it wasn't down already...
			if not GUI.mouse.last_r_down then

				-- Was a different element clicked?
				if not inside then 
					--elm.focus = false
				else
		
						-- Double clicked?
					if GUI.mouse.r_downtime and reaper.time_precise() - GUI.mouse.r_downtime < 0.20 then
						
						GUI.mouse.r_downtime = nil
						GUI.mouse.r_dbl_clicked = true
						elm:onr_doubleclick()
						
					elseif not GUI.mouse.r_dbl_clicked then
			
						elm:onmouser_down()
						
					end
					
					GUI.mouse.r_down = true
					GUI.mouse.r_ox, GUI.mouse.r_oy = x, y
					GUI.elm_updated = true
				
				end
				
		
			-- 		Dragging? 									Did the mouse start out in this element?
			elseif (x ~= GUI.mouse.r_lx or y ~= GUI.mouse.r_ly) and GUI.IsInside(elm, GUI.mouse.r_ox, GUI.mouse.r_oy) then
			
				if elm.focus ~= false then 

					elm:onr_drag()
					GUI.elm_updated = true

				end

			end

		-- If it was originally clicked in this element and has now been released
		elseif GUI.mouse.r_down and GUI.IsInside(elm, GUI.mouse.r_ox, GUI.mouse.r_oy) then 
		
			if not GUI.mouse.r_dbl_clicked then elm:onmouser_up() end

			GUI.elm_updated = true
			GUI.mouse.r_down = false
			GUI.mouse.r_dbl_clicked = false
			GUI.mouse.r_ox, GUI.mouse.r_oy = -1, -1
			GUI.mouse.r_lx, GUI.mouse.r_ly = -1, -1
			GUI.mouse.r_downtime = reaper.time_precise()

		end



		-- Middle button
		if GUI.mouse.cap&64==64 then
			
			
			-- If it wasn't down already...
			if not GUI.mouse.last_m_down then


				-- Was a different element clicked?
				if not inside then 

				else	
					-- Double clicked?
					if GUI.mouse.m_downtime and reaper.time_precise() - GUI.mouse.m_downtime < 0.20 then

						GUI.mouse.m_downtime = nil
						GUI.mouse.m_dbl_clicked = true
						elm:onm_doubleclick()

					else
					
						elm:onmousem_down()					

					end				

					GUI.mouse.m_down = true
					GUI.mouse.m_ox, GUI.mouse.m_oy = x, y
					GUI.elm_updated = true

				end
				

			
			-- 		Dragging? 									Did the mouse start out in this element?
			elseif (x ~= GUI.mouse.m_lx or y ~= GUI.mouse.m_ly) and GUI.IsInside(elm, GUI.mouse.m_ox, GUI.mouse.m_oy) then
			
				if elm.focus ~= false then 
					
					elm:onm_drag()
					GUI.elm_updated = true
					
				end

			end

		-- If it was originally clicked in this element and has now been released
		elseif GUI.mouse.m_down and GUI.IsInside(elm, GUI.mouse.m_ox, GUI.mouse.m_oy) then
		
			if not GUI.mouse.m_dbl_clicked then elm:onmousem_up() end
			
			GUI.elm_updated = true
			GUI.mouse.m_down = false
			GUI.mouse.m_dbl_clicked = false
			GUI.mouse.m_ox, GUI.mouse.m_oy = -1, -1
			GUI.mouse.m_lx, GUI.mouse.m_ly = -1, -1
			GUI.mouse.m_downtime = reaper.time_precise()

		end


	end
	
		
	
	-- If the mouse is hovering over the element
	if inside and not GUI.mouse.down and not GUI.mouse.r_down then
		elm:onmouseover()
		--GUI.elm_updated = true
		elm.mouseover = true
	else
		elm.mouseover = false
		--elm.hovering = false
	end
	
	
	-- If the mousewheel's state has changed
	if inside and GUI.mouse.wheel ~= GUI.mouse.lwheel then
		
		GUI.mouse.inc = (GUI.mouse.wheel - GUI.mouse.lwheel) / 120
		
		elm:onwheel()
		GUI.elm_updated = true
		GUI.mouse.lwheel = GUI.mouse.wheel
	
	end
	
	-- If the element is in focus and the user typed something
	if elm.focus and GUI.char ~= 0 then
		elm:ontype() 
		GUI.elm_updated = true
	end
	
end



--[[	Return or change an element's value
	
	For use with external user functions. Returns the given element's current 
	value or, if specified, sets a new one.	Changing values with this is often 
	preferable to setting them directly, as most :val methods will also update 
	some internal parameters and redraw the element when called.
]]--
GUI.Val = function (elm, newval)

	if not GUI.elms[elm] then return nil end
	
	if newval then
		GUI.elms[elm]:val(newval)
	else
		return GUI.elms[elm]:val()
	end

end



-- Wrapper for creating new elements, allows them to know their own name
-- If called after the script window has opened, will also run their :init
-- method.
GUI.New = function (name, elm, ...)
	
	if not GUI[elm] then
		reaper.ShowMessageBox("Unable to create element '"..tostring(name).."'.\nClass '"..tostring(elm).."'isn't available.", "GUI Error", 0)
		GUI.quit = true
		return 0
	end
	
	GUI.elms[name] = GUI[elm]:new(name, ...)	
	if GUI.gfx_open then GUI.elms[name]:init() end
	
end




--[[
	All classes will use this as their template, so that
	elements are initialized with every method available.
]]--
GUI.Element = {}
function GUI.Element:new(name)
	
	local elm = {}
	if name then elm.name = name end
	
	setmetatable(elm, self)
	self.__index = self
	return elm
	
end

-- Called a) when the script window is first opened
-- 		  b) when any element is created via GUI.New after that
-- i.e. Elements can draw themselves to a buffer once on :init()
-- and then just blit/rotate/etc as needed afterward
function GUI.Element:init() end

-- Called on every update loop, unless the element is hidden or frozen
function GUI.Element:onupdate() end

-- Called when the element is deleted by GUI.update_elms_list()
-- Use it for freeing up buffers, or anything else memorywise that this
-- element was doing
function GUI.Element:ondelete() end

-- Set or return the element's value
-- Can be useful for something like a Slider that doesn't have the same
-- value internally as what it's displaying
function GUI.Element:val() end

-- Updates the current tooltip, if necessary
function GUI.Element:onmouseover()
	
	if self.tooltip and not GUI.tooltip_elm then 
		GUI.tooltip_elm = self 
	end

end



-- Only called once; won't repeat if the button is held
function GUI.Element:onmousedown() end

function GUI.Element:onmouseup() end
function GUI.Element:ondoubleclick() end

-- Will continue being called even if you drag outside the element
function GUI.Element:ondrag() end

-- Right-click equivalents
function GUI.Element:onmouser_down() end
function GUI.Element:onmouser_up() end
function GUI.Element:onr_doubleclick() end
function GUI.Element:onr_drag() end

-- Middle-click equivalents
function GUI.Element:onmousem_down() end
function GUI.Element:onmousem_up() end
function GUI.Element:onm_doubleclick() end
function GUI.Element:onm_drag() end


function GUI.Element:onwheel() end
function GUI.Element:ontype() end



-- For elements like a Textbox that need to keep track of their
-- focus state; use this to e.g. store the text somewhere else
-- when the user clicks out of the box.
function GUI.Element:lostfocus() end




--[[
	To create a new class, just use:
	
		-- Creates a new child of GUI.Element
		GUI.My_Class = GUI.Element:new()
		
		--					The element's name, i.e. "lbl_version"
		--							The element's z layer
		--									Coords and size
		--												Whatever other parameters you want
		function GUI.My_Class:new(name, z [, x, y, w, h, param_a, param_b, param_c, param_d])
		
			-- Every class object is really just a big table
			local class = {}
			
			-- These are the only parameters that are strictly necessary
			class.name = name
			class.z = z

			-- However, if you want your class to use any of the methods,
			-- you'll need x, y, w, and h:
			class.x = x
			class.y = y
			class.w = w
			class.h = h

			-- Store the parameters this object was created with
			class.param_a = param_a
			class.param_b = param_b
			class.param_c = param_c
			class.param_d = param_d
		
			-- Force a redraw for this object's layer, since presumably we want to see it
			GUI.redraw_z[z] = true
		
		
			-- More class stuff. Roughly, it's just telling the new object to use GUI.my_class
			-- as a reference for anything it needs, which in turn will use GUI.Element as
			-- its own reference.
			
			setmetatable(class, self)
			self.__index = self
			
			-- Return the new child object
			return class
		
		end
	
	
	To create an object of class My_Class:
	GUI.New("my_element", "My_Class", z, x, y, w, h......)	
	
	
	
	Methods are added by:
	
		function GUI.My_Class:fade()
	
			blah blah blah
			
		end
		
	Methods can be modified at run-time like so:
	
		
		function GUI.elms.my_button:draw()
			GUI.Button.draw(self)				-- Include the original method
			...do other stuff...
		end
		
		- The original method call ^ isn't necessary; methods can be rewritten from scratch if
		  you'd like. It can also be called before, after, or in the middle of your function.
	  
		- If it *isn't* used, you'll need to include
				GUI.redraw_z[self.z] = true
		  in order for the element to be redrawn when that method is called.
		
	
	- All of the methods listed for GUI.Element will be called when appropriate on each loop
	  of GUI.Update. Any methods that aren't listed there can be called on their own as a
	  function. To fade a label, for instance:
	  
		my_label:fade(2, 3, 10)
		
]]--







-- Make our table full of functions available to the parent script
return GUI

end
GUI = GUI_table()

----------------------------------------------------------------
----------------------------To here-----------------------------
----------------------------------------------------------------
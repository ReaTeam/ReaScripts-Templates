--[[	Lokasenna_GUI - MenuBox class
	
	---- User parameters ----
	
	(name, z, x, y, w, h, caption, opts)
	
Required:
z				Element depth, used for hiding and disabling layers. 1 is the highest.
x, y			Coordinates of top-left corner
w, h
caption			Label displayed to the left of the menu box
opts			Comma-separated string of options. As with gfx.showmenu, there are
				a few special symbols that can be added at the beginning of an option:
				
					# : grayed out
					> : this menu item shows a submenu
					< : last item in the current submenu
					An empty field will appear as a separator in the menu.
					
				
				
Optional:
pad				Padding between the label and the box


Additional:
bg				Color to be drawn underneath the label. Defaults to "wnd_bg"
font_a			Font for the menu's label
font_b			Font for the menu's current value


Extra methods:



GUI.Val()		Returns the current menu option, numbered from 1. Numbering does include
				separators and submenus:
				
					New					1
					--					
					Open				3
					Save				4
					--					
					Recent	>	a.txt	7
								b.txt	8
								c.txt	9
					--
					Options				11
					Quit				12
										
GUI.Val(new)	Sets the current menu option, numbered as above.


]]--

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end



GUI.Menubox = GUI.Element:new()
function GUI.Menubox:new(name, z, x, y, w, h, caption, opts)
	
	local menu = {}
	
	menu.name = name
	menu.type = "Menubox"
	
	menu.z = z
	GUI.redraw_z[z] = true	
	
	menu.x, menu.y, menu.w, menu.h = x, y, w, h

	menu.caption = caption
	menu.bg = "wnd_bg"
	
	menu.font_a = 3
	menu.font_b = 4
	
	menu.col_cap = "txt"
	menu.col_txt = "txt"
	
	menu.pad = pad or 4
	
	-- Parse the string of options into a table
	menu.optarray = {}
	local tempidx = 1

	for word in string.gmatch(opts, '([^,]+)') do
		menu.optarray[tempidx] = word
		tempidx = tempidx + 1
	end
	
	menu.retval = 1
	menu.numopts = tempidx - 1
	
	setmetatable(menu, self)
    self.__index = self 
    return menu
	
end


function GUI.Menubox:init()
	
	local w, h = self.w, self.h
	
	self.buff = GUI.GetBuffer()
	
	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2*w + 4, 2*h + 4)
	
	local r, g, b, a = table.unpack(GUI.colors["shadow"])
	gfx.set(r, g, b, 1)
	gfx.rect(w + 3, 1, w, h, 1)
	gfx.muladdrect(w + 3, 1, w + 2, h + 2, 1, 1, 1, a, 0, 0, 0, 0 )
	
	GUI.color("elm_bg")
	gfx.rect(1, 1, w, h)
	gfx.rect(1, w + 3, w, h)
	
	GUI.color("elm_frame")
	gfx.rect(1, 1, w, h, 0)
	gfx.rect(1 + w - h, 1, h, h, 1)
	
	GUI.color("elm_fill")
	gfx.rect(1, h + 3, w, h, 0)
	gfx.rect(2, h + 4, w - 2, h - 2, 0)
	gfx.rect(1 + w - h, h + 3, h, h, 1)
	
	GUI.color("elm_bg")
	
	-- Triangle size
	local r = 5
	local rh = 2 * r / 5
	
	local ox = (1 + w - h) + h / 2
	local oy = 1 + h / 2 - (r / 2)

	local Ax, Ay = GUI.polar2cart(1/2, r, ox, oy)
	local Bx, By = GUI.polar2cart(0, r, ox, oy)
	local Cx, Cy = GUI.polar2cart(1, r, ox, oy)
	
	GUI.triangle(1, Ax, Ay, Bx, By, Cx, Cy)
	
	oy = oy + h + 2
	
	Ax, Ay = GUI.polar2cart(1/2, r, ox, oy)
	Bx, By = GUI.polar2cart(0, r, ox, oy)
	Cx, Cy = GUI.polar2cart(1, r, ox, oy)	
	
	GUI.triangle(1, Ax, Ay, Bx, By, Cx, Cy)	

end




-- Menubox - Draw
function GUI.Menubox:draw()	
	
	local x, y, w, h = self.x, self.y, self.w, self.h
	
	local caption = self.caption
	local val = self.retval
	local text = self.optarray[val]

	local focus = self.focus
	

	-- Draw the caption
	GUI.font(self.font_a)
	local str_w, str_h = gfx.measurestr(caption)
	gfx.x = x - str_w - self.pad
	gfx.y = y + (h - str_h) / 2
	GUI.text_bg(caption, self.bg)
	GUI.shadow(caption, self.col_cap, "shadow")
	
	for i = 1, GUI.shadow_dist do
		gfx.blit(self.buff, 1, 0, w + 2, 0, w + 2, h + 2, x + i - 1, y + i - 1)	
	end
	
	
	gfx.blit(self.buff, 1, 0, 0, (focus and (h + 2) or 0) , w + 2, h + 2, x - 1, y - 1) 	
	
	
	--[[
	-- Draw the frame background
	GUI.color("elm_bg")
	gfx.rect(x, y, w, h, 1)
	
	
	-- Draw the frame, and make it brighter if focused.
	if focus then 
				
		GUI.color("elm_fill")
		gfx.rect(x + 1, y + 1, w - 2, h - 2, 0)
		
	else
	
		GUI.color("elm_frame")
	end

	gfx.rect(x, y, w, h, 0)

	-- Draw the dropdown indicator
	gfx.rect(x + w - h, y, h, h, 1)
	GUI.color("elm_bg")
	
	-- Triangle size
	local r = 6
	local rh = 2 * r / 5
	
	local ox = (x + w - h) + h / 2
	local oy = y + h / 2 - (r / 2)

	local Ax, Ay = GUI.polar2cart(1/2, r, ox, oy)
	local Bx, By = GUI.polar2cart(0, r, ox, oy)
	local Cx, Cy = GUI.polar2cart(1, r, ox, oy)
	
	GUI.triangle(1, Ax, Ay, Bx, By, Cx, Cy)
	]]--

	-- Draw the text
	GUI.font(self.font_b)
	GUI.color(self.col_txt)
	
	if self.output then text = self.output(text) end

	str_w, str_h = gfx.measurestr(text)
	gfx.x = x + 4
	gfx.y = y + (h - str_h) / 2
	gfx.drawstr(text)
	
end


-- Menubox - Get/set value
function GUI.Menubox:val(newval)
	
	if newval then
		self.retval = newval
		GUI.redraw_z[self.z] = true		
	else
		return math.floor(self.retval)
	end
	
end


-- Menubox - Mouse up
function GUI.Menubox:onmouseup()

	local menu_str = ""
	local str_arr = {}
	
	-- The menu doesn't count separators in the returned number,
	-- so we'll do it here
	local sep_arr = {}
	
	for i = 1, self.numopts do
		
		-- Check off the currently-selected option
		if i == self.retval then menu_str = menu_str .. "!" end


		if type(self.optarray[i]) == "table" then
			table.insert( str_arr, tostring(self.optarray[i][1]) )
		else
			table.insert( str_arr, tostring(self.optarray[i]) )
		end

		if str_arr[#str_arr] == ""
		or string.sub(str_arr[#str_arr], 1, 1) == ">" then 
			table.insert(sep_arr, i) 
		end

		table.insert( str_arr, "|" )

	end
	
	menu_str = table.concat( str_arr )
	
	menu_str = string.sub(menu_str, 1, string.len(menu_str) - 1)

	gfx.x, gfx.y = GUI.mouse.x, GUI.mouse.y
	
	local curopt = gfx.showmenu(menu_str)
	
	if #sep_arr > 0 then
		for i = 1, #sep_arr do
			if curopt >= sep_arr[i] then
				curopt = curopt + 1
			else
				break
			end
		end
	end
	
	if curopt ~= 0 then self.retval = curopt end

	self.focus = false
	
	GUI.redraw_z[self.z] = true	
end


-- Menubox - Mouse down
-- This is only so that the box will light up
function GUI.Menubox:onmousedown()
	GUI.redraw_z[self.z] = true
end

-- Menubox - Mousewheel
function GUI.Menubox:onwheel()
	
	local curopt = self.retval - GUI.mouse.inc
	local inc = (GUI.mouse.inc > 0) and 1 or -1

	-- Check for illegal values, separators, and submenus
	while true do
		
		if curopt < 1 then 
			curopt = 1 
			inc = 1
		elseif curopt > self.numopts then 
			curopt = self.numopts 
			inc = -1
		end	

		if self.optarray[curopt] == "" or string.sub( self.optarray[curopt], 1, 1 ) == ">" then 
			curopt = curopt - inc

		else
		
			-- All good, let's move on
			break
		end
		
	end
	

	
	self.retval = curopt
	
	GUI.redraw_z[self.z] = true	
end


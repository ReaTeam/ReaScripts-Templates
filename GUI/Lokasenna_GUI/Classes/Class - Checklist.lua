--[[	Lokasenna_GUI - Checklist class
	
	Adapted from eugen2777's simple GUI template.
	
	---- User parameters ----

	(name, z, x, y, w, h, caption, opts[, dir, pad])
	
Required:
z				Element depth, used for hiding and disabling layers. 1 is the highest.
x, y			Coordinates of top-left corner
caption			Checklist title. Feel free to just use a blank string: ""
opts			Comma-separated string of checklist options

				Options can be skipped to create a gap in the list by using "__":
				
				opts = "Alice,Bob,Charlie,__,Edward,Francine"
				->
				Alice
				Bob
				Charlie
				
				Edward
				Francine

Optional:
dir				*** Currently does nothing, dir will always be 'v'***
				"h"		Boxes will extend to the right, with labels above them
				"v"		Boxes will extend downward, with labels to their right
pad				Separation in px between boxes


Additional:
bg				Color to be drawn underneath the label. Defaults to "wnd_bg"
chk_w			Size of each checkbox in px. Defaults to 20.
				* Changing this might screw with the spacing of your check boxes *
col_txt			Text color
col_fill		Checked box color
font_a			List title font
font_b			List option font
frame			Boolean. Draw a frame around the options? Defaults to true.
shadow			Boolean. Draw a shadow under the text? Defaults to true.
swap			If dir = "h", draws the option labels below the boxes rather than above
						 "v", draws the option labels to the left of the boxes rather than right
optarray[i]		Options' labels are stored here. Indexed from 1.
optsel[i]		Boolean. Options' checked states are stored here. Indexed from 1.



Extra methods:



GUI.Val()		Returns self.optsel as a table of boolean values for each option. Indexed from 1.
GUI.Val(new)	Accepts a table of boolean values for each option. Indexed from 1.
	
]]--

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end


-- Checklist - New
GUI.Checklist = GUI.Element:new()
function GUI.Checklist:new(name, z, x, y, w, h, caption, opts, dir, pad)
	
	local chk = {}
	
	chk.name = name
	chk.type = "Checklist"
	
	chk.z = z
	GUI.redraw_z[z] = true	
	
	chk.x, chk.y, chk.w, chk.h = x, y, w, h
	
	-- constant for the square size
	chk.chk_w = 20

	chk.caption = caption
	chk.bg = "wnd_bg"
	
	chk.dir = dir or "v"
	
	chk.pad = pad or 4
	
	chk.col_txt = "txt"
	chk.col_fill = "elm_fill"
	
	chk.font_a = 2
	chk.font_b = 3
	
	chk.frame = true
	
	chk.shadow = true
	
	chk.swap = false

	-- Parse the string of options into a table
	chk.optarray, chk.optsel = {}, {}
	local tempidx = 1
	for word in string.gmatch(opts, '([^,]+)') do
		chk.optarray[tempidx] = word
		chk.optsel[tempidx] = false
		tempidx = tempidx + 1
	end
	
	
	chk.retval = chk.optsel

	setmetatable(chk, self)
    self.__index = self 
    return chk
	
end


function GUI.Checklist:init()
	
	self.buff = self.buff or GUI.GetBuffer()
	
	local w = self.chk_w
	
	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2*w + 4, w + 2)
	
	GUI.color("elm_frame")
	gfx.rect(1, 1, w, w, 0)
	
	GUI.color(self.col_fill)
	gfx.rect(w + 3 + 0.25*w, 1 + 0.25*w, 0.5*w, 0.5*w, 1)
	
	if self.caption ~= "" then
		GUI.font(self.font_a)
		local str_w, str_h = gfx.measurestr(self.caption)
		self.cap_h = 0.5*str_h
		self.cap_x = self.x + (self.w - str_w) / 2	
	else
		self.cap_h = 0
		self.cap_x = 0
	end
	
end



-- Checklist - Draw
function GUI.Checklist:draw()
	
	
	local x, y, w, h = self.x, self.y, self.w, self.h

	local dir = self.dir
	local pad = self.pad
	local f_color = self.col_fill
	
	-- Draw the element frame
	if self.frame then
		GUI.color("elm_frame")
		gfx.rect(x, y, w, h, 0)
	end	
	
	if self.caption ~= "" then
		GUI.font(self.font_a)
		
		gfx.x = self.cap_x
		gfx.y = y - self.cap_h
		
		GUI.text_bg(self.caption, self.bg)
		
		GUI.shadow(self.caption, self.col_txt, "shadow")
		
		y = y + self.cap_h + pad
	end


	-- Draw the options
	GUI.color("txt")

	local size = self.chk_w
	
	-- Set the options slightly into the frame
	x, y = x + 0.5*pad, y + 0.5*pad
	
	-- If horizontal, leave some extra space for labels
	if dir == "h" and self.caption ~= "" and not self.swap then y = y + self.cap_h + 2*pad end	
	local x_adj, y_adj = table.unpack(dir == "h" and { (size + pad), 0 } or { 0, (size + pad) })
	
	GUI.font(self.font_b)

	for i = 1, #self.optarray do
		
		local str = self.optarray[i]
		
		if str ~= "__" then
		
			local opt_x, opt_y = x + (i - 1) * x_adj, y + (i - 1) * y_adj
			
			-- Draw the option frame
			--GUI.color("elm_frame")
			--gfx.rect(opt_x, opt_y, size, size, 0)
			gfx.blit(self.buff, 1, 0, 1, 1, size, size, opt_x, opt_y)
					
			-- Fill in if selected
			if self.optsel[i] == true then
				
				--GUI.color(f_color)
				--gfx.rect(opt_x + size * 0.25, opt_y + size * 0.25, size / 2, size / 2, 1)
				gfx.blit(self.buff, 1, 0, size + 3, 1, size, size, opt_x, opt_y)
			
			end
		
			
			local str_w, str_h = gfx.measurestr(self.optarray[i])
			local swap = self.swap
			
			if dir == "h" then
				if not swap then
					gfx.x, gfx.y = opt_x + (size - str_w) / 2, opt_y - size
				else
					gfx.x, gfx.y = opt_x + (size - str_w) / 2, opt_y + size + 4
				end
			else
				if not swap then
					gfx.x, gfx.y = opt_x + 1.5 * size, opt_y + (size - str_h) / 2
				else
					gfx.x, gfx.y = opt_x - str_w - 8, opt_y + (size - str_h) / 2
				end
			end
	
		
			GUI.text_bg(self.optarray[i], self.bg)
			if #self.optarray == 1 or self.shadow then
				GUI.shadow(self.optarray[i], self.col_txt, "shadow")
			else
				GUI.color(self.col_txt)
				gfx.drawstr(self.optarray[i])
			end
		end
		
	end
	
end


-- Checklist - Get/set value. Returns a table of boolean values for each option.
function GUI.Checklist:val(new)
	
	if new then
		if type(new) == "table" then
			for i = 1, #new do
				self.optsel[i] = new[i]
			end
			GUI.redraw_z[self.z] = true	
		end
	else
		return self.optsel
	end
	
end


-- Checklist - Mouse down
function GUI.Checklist:onmouseup()

	-- See which option it's on
	local mouseopt = self.dir == "h" 	and (GUI.mouse.x - (self.x + 0.5*self.chk_w))
										or	(GUI.mouse.y - (self.y + self.cap_h) )
	mouseopt = mouseopt / ((self.chk_w + self.pad) * #self.optarray)
	mouseopt = GUI.clamp( math.floor(mouseopt * #self.optarray) + 1 , 1, #self.optarray )
	
	-- Toggle that option
	
	self.optsel[mouseopt] = not self.optsel[mouseopt] 

	GUI.redraw_z[self.z] = true
	--self:val()
	
end


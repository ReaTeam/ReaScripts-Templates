--[[	Lokasenna_GUI - Radio class
	
	Adapted from eugen2777's simple GUI template.
	
	---- User parameters ----
	
	(name, z, x, y, w, h, caption, opts[, dir, pad])
	
Required:
z				Element depth, used for hiding and disabling layers. 1 is the highest.
x, y			Coordinates of top-left corner
caption			Radio button title. Feel free to just use a blank string: ""
opts			Comma-separated string of radio options

				Options can be skipped to create a gap in the list by using "__":
				
				opts = "Alice,Bob,Charlie,__,Edward,Francine"
				->
				Alice
				Bob
				Charlie
				
				Edward
				Francine


Optional:
dir				"h"		Bubbles will extend to the right, with labels above them
				"v"		Bubbles will extend downward, with labels to their right
pad				Separation in px between bubbles. Defaults to 4.


Additional:
bg				Color to be drawn underneath the caption. Defaults to "wnd_bg"
frame			Boolean. Draw a frame around the options.
radius			Radius of the unfilled bubbles in px. Defaults to 10.
				* Changing this might screw with the spacing of your bubbles *
col_txt			Text color
col_fill		Filled bubble color
font_a			List title font
font_b			List option font
shadow			Boolean. Draw a shadow under the text? Defaults to true.
swap			If dir = "h", draws the option labels below the bubbles rather than above
						 "v", draws the option labels to the left of the bubbles rather than right


Extra methods:



GUI.Val()		Returns the current option, numbered from 1.
GUI.Val(new)	Sets the current option, numbered from 1.

]]--

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

-- Radio - New.
GUI.Radio = GUI.Element:new()
function GUI.Radio:new(name, z, x, y, w, h, caption, opts, dir, pad)
	
	local radio = {}
	
	radio.name = name
	radio.type = "Radio"
	
	radio.z = z
	GUI.redraw_z[z] = true	
	
	radio.x, radio.y, radio.w, radio.h = x, y, w, h

	radio.caption = caption
	radio.col_txt = "txt"
	radio.col_fill = "elm_fill"
	radio.bg = "wnd_bg"
	
	radio.frame = true

	radio.font_a = 2
	radio.font_b = 3
	
	radio.dir = dir
	radio.pad = pad
	
	-- Size of the option bubbles
	radio.radius = 10
	
	-- Parse the string of options into a table
	radio.optarray = {}
	local tempidx = 1
	for word in string.gmatch(opts, '([^,]+)') do
		radio.optarray[tempidx] = word
		tempidx = tempidx + 1
	end
	
	radio.shadow = true
	
	-- Currently-selected option
	radio.retval, radio.state = 1, 1
	
	setmetatable(radio, self)
    self.__index = self 
    return radio
	
end


function GUI.Radio:init()
	
	self.buff = self.buff or GUI.GetBuffer()
	
	local r = self.radius
	
	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 4*r + 4, 2*r + 2)
	
	-- Option bubble
	GUI.color(self.bg)
	gfx.circle(r + 1, r + 1, r + 2, 1, 0)
	gfx.circle(3*r + 3, r + 1, r + 2, 1, 0)
	GUI.color("elm_frame")
	gfx.circle(r + 1, r + 1, r, 0)
	gfx.circle(3*r + 3, r + 1, r, 0)
	GUI.color(self.col_fill)
	gfx.circle(3*r + 3, r + 1, 0.5*r, 1)
	
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


-- Radio - Draw.
function GUI.Radio:draw()
	
	
	local x, y, w, h = self.x, self.y, self.w, self.h
	local r = self.radius

	local dir = self.dir
	local pad = self.pad
	
	-- Draw the element frame
	if self.frame then
		GUI.color("elm_frame")
		gfx.rect(x, y, w, h, 0)
	end

	-- Draw the caption

	if self.caption ~= "" then
		GUI.font(self.font_a)
		
		gfx.x = self.cap_x
		gfx.y = y - self.cap_h
		
		GUI.text_bg(self.caption, self.bg)
		
		GUI.shadow(self.caption, self.col_txt, "shadow")
		
		y = y + self.cap_h + pad		
	end
	
	GUI.font(self.font_b)

	-- Draw the options
	--local optheight = (h - self.capheight - 2 * pad) / #self.optarray
	--[[
	local optheight = 2*r + pad
	local cur_y = y + self.cap_h + pad
	
	for i = 1, #self.optarray do	
	--gfx.blit(source, scale, rotation[, srcx, srcy, srcw, srch, destx, desty, destw, desth, rotxoffs, rotyoffs] )	
		gfx.blit(self.buff, 1, 0, ( i == self.state and (2*r + 2) or 0 ), 0, 2*r + 2, 2*r + 2, x + r, cur_y)
		
		
		-- Labels
		--GUI.color("txt")
		local str = self.optarray[i]
		local str_w, str_h = gfx.measurestr(str)
		
		gfx.x = x + 4 * r
		gfx.y = cur_y + (optheight - str_h) / 2
		
		GUI.text_bg(str, self.bg)
		
		if self.shadow then
			GUI.shadow(str, self.col_txt, "shadow")
		else
			GUI.color(self.col_xt)
			gfx.drawstr(str)
		end
		
		cur_y = cur_y + optheight

		
	end
	]]--
	
	local size = 2*r
	x, y = x + 0.5*pad, y + 0.5*pad
	if dir == "h" and self.caption ~= "" and not self.swap then y = y + self.cap_h + 2*pad end
	local x_adj, y_adj = table.unpack(dir == "h" and { (size + pad), 0 } or { 0, (size + pad) } )

	for i = 1, #self.optarray do
	
		local str = self.optarray[i]
		
		if str ~= "__" then
		
			local opt_x, opt_y = x + (i - 1) * x_adj, y + (i - 1) * y_adj
			
			-- Draw the option frame
			--GUI.color("elm_frame")
			--gfx.rect(opt_x, opt_y, size, size, 0)
			gfx.blit(self.buff, 1, 0, 1, 1, size + 1, size + 1, opt_x, opt_y)
					
			-- Fill in if selected
			if self.state == i then
				
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


-- Radio - Get/set value
function GUI.Radio:val(newval)
	
	if newval then
		self.retval = newval
		self.state = newval
		GUI.redraw_z[self.z] = true		
	else
		return self.retval
	end	
	
end


-- Radio - Mouse down.
function GUI.Radio:onmousedown()
	--[[		
	--See which option it's on
	local adj_y = self.y + self.cap_h + self.pad
	--local adj_h = self.h - self.capheight - self.pad
	local adj_h = (2*self.radius + self.pad) * #self.optarray
	local mouseopt = (GUI.mouse.y - adj_y) / adj_h
		
	mouseopt = GUI.clamp( math.floor(mouseopt * #self.optarray) + 1 , 1, #self.optarray)
	]]--
	
	-- See which option it's on
	local mouseopt = self.dir == "h" 	and (GUI.mouse.x - (self.x + self.radius))
										or	(GUI.mouse.y - (self.y + self.cap_h) )
	mouseopt = mouseopt / ((2*self.radius + self.pad) * #self.optarray)
	mouseopt = GUI.clamp( math.floor(mouseopt * #self.optarray) + 1 , 1, #self.optarray )

	self.state = mouseopt

	GUI.redraw_z[self.z] = true

end


-- Radio - Mouse up
function GUI.Radio:onmouseup()
		
	-- Set the new option, or revert to the original if the cursor isn't inside the list anymore
	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) then
		self.retval = self.state
	else
		self.state = self.retval	
	end

	GUI.redraw_z[self.z] = true

end


-- Radio - Dragging
function GUI.Radio:ondrag() 

	self:onmousedown()

	GUI.redraw_z[self.z] = true

end


-- Radio - Mousewheel
function GUI.Radio:onwheel()
	
	self.state = self.state + (self.dir == "h" and 1 or -1) * GUI.mouse.inc
	
	if self.state < 1 then self.state = 1 end
	if self.state > #self.optarray then self.state = #self.optarray end
	
	self.retval = self.state

	GUI.redraw_z[self.z] = true

end



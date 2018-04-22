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

	radio.frame = true
	radio.bg = "wnd_bg"
    
	radio.dir = dir or "v"
	radio.pad = pad or 4
        
	radio.col_txt = "txt"
	radio.col_fill = "elm_fill"

	radio.font_a = 2
	radio.font_b = 3
	
	radio.shadow = true
	
    radio.swap = false
    
	-- Size of the option bubbles
	radio.radius = 10
	
	-- Parse the string of options into a table
	radio.optarray = {}
	local tempidx = 1
	for word in string.gmatch(opts, '([^,]+)') do
		radio.optarray[tempidx] = word
		tempidx = tempidx + 1
	end
		
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
	
	if self.frame then
		GUI.color("elm_frame")
		gfx.rect(self.x, self.y, self.w, self.h, 0)
	end

    if self.caption and self.caption ~= "" then self:drawcaption() end

    self:drawoptions()

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




------------------------------------
-------- Input methods -------------
------------------------------------


-- Radio - Mouse down.
function GUI.Radio:onmousedown()
	
    local len = #self.optarray
    
	-- See which option it's on
	local mouseopt = self.dir == "h" 	
                    and (GUI.mouse.x - (self.x + self.pad))
					or	(GUI.mouse.y - (self.y + self.cap_h + 1.5*self.pad) )
	mouseopt = mouseopt / ((2*self.radius + self.pad) * len)
	mouseopt = GUI.clamp( math.floor(mouseopt * len) + 1 , 1, len )

	self.state = mouseopt

	GUI.redraw_z[self.z] = true

end


-- Radio - Mouse up
function GUI.Radio:onmouseup()
		
	-- Set the new option, or revert to the original if the cursor 
    -- isn't inside the list anymore
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
	
	self.state = GUI.round(self.state +     (self.dir == "h" and 1 or -1) 
                                        *    GUI.mouse.inc)
	
	if self.state < 1 then self.state = 1 end
	if self.state > #self.optarray then self.state = #self.optarray end
	
	self.retval = self.state

	GUI.redraw_z[self.z] = true

end




------------------------------------
-------- Drawing methods -----------
------------------------------------


function GUI.Radio:drawcaption()
    
    GUI.font(self.font_a)
    
    gfx.x = self.cap_x
    gfx.y = self.y - self.cap_h
    
    GUI.text_bg(self.caption, self.bg)
    
    GUI.shadow(self.caption, self.col_txt, "shadow")
    
end


function GUI.Radio:drawoptions()

    local x, y, w, h = self.x, self.y, self.w, self.h
    
    local horz = self.dir == "h"
	local pad = self.pad
    
    -- Bump everything down for the caption
    y = y + self.cap_h + 1.5 * pad 

    -- Bump the options down more for horizontal options
    -- with the text on top
	if horz and self.caption ~= "" and not self.swap then
        y = y + self.cap_h + 2*pad 
    end

	local size = 2 * self.radius
    
    local adj = size + pad

    local str, opt_x, opt_y

	for i = 1, #self.optarray do
	
		str = self.optarray[i]
		if str ~= "__" then
		        
            opt_x = x + (horz   and (i - 1) * adj + pad
                                or  (self.swap  and (w - adj - 1) 
                                                or   pad))
                                                
            opt_y = y + (i - 1) * (horz and 0 or adj)
                
			-- Draw the option bubble
            self:drawbubble(opt_x, opt_y, size, i == self.state)

            self:drawvalue(opt_x,opt_y, size, str)
            
		end
		
	end
	
end


function GUI.Radio:drawbubble(opt_x, opt_y, size, selected)
    
    gfx.blit(   self.buff, 1,  0,  
                selected and (size + 3) or 1, 1, 
                size + 1, size + 1, 
                opt_x, opt_y)

end


function GUI.Radio:drawvalue(opt_x, opt_y, size, str)

	GUI.font(self.font_b) 

    local str_w, str_h = gfx.measurestr(str)
    
    if self.dir == "h" then
        
        gfx.x = opt_x + (size - str_w) / 2
        gfx.y = opt_y + (self.swap and (size + 4) or -size)

    else
    
        gfx.x = opt_x + (self.swap and -(str_w + 8) or 1.5*size)
        gfx.y = opt_y + (size - str_h) / 2
        
    end

    GUI.text_bg(str, self.bg)
    if #self.optarray == 1 or self.shadow then
        GUI.shadow(str, self.col_txt, "shadow")
    else
        GUI.color(self.col_txt)
        gfx.drawstr(str)
    end

end
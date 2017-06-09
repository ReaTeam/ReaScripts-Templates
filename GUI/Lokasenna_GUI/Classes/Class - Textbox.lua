--[[	Lokasenna_GUI - Textbox class
	
	---- User parameters ----

	(name, z, x, y, w, h[, caption, pad])

Required:
z				Element depth, used for hiding and disabling layers. 1 is the highest.
x, y			Coordinates of top-left corner
w, h			Width and height of the textbox

Optional:
caption			Label shown to the left of the textbox
pad				Padding between the label and the textbox


Additional:
bg				Color to be drawn underneath the label. Defaults to "wnd_bg"
shadow			Boolean. Draw a shadow beneath the label?
color			Text color
font_a			Label font
font_b			Text font

focus			Whether the textbox is "in focus" or not, allowing users to type.
				This setting is automatically updated, so you shouldn't need to
				change it yourself in most cases.
				

Extra methods:


GUI.Val()		Returns self.optsel as a table of boolean values for each option. Indexed from 1.
GUI.Val(new)	Accepts a table of boolean values for each option. Indexed from 1.


]]--

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

-- Textbox - New
GUI.Textbox = GUI.Element:new()
function GUI.Textbox:new(name, z, x, y, w, h, caption, pad)
	
	local txt = {}
	
	txt.name = name
	txt.type = "Textbox"
	
	txt.z = z
	GUI.redraw_z[z] = true	
	
	txt.x, txt.y, txt.w, txt.h = x, y, w, h

	txt.caption = caption or ""
	txt.pad = pad or 4
	
	txt.shadow = true
	txt.bg = "wnd_bg"
	txt.color = "txt"
	
	txt.font_a = 3
	txt.font_b = 4
	
	txt.caret = 0
	txt.sel = 0
	txt.blink = 0
	txt.retval = ""
	txt.focus = false
	
	setmetatable(txt, self)
	self.__index = self
	return txt

end


function GUI.Textbox:init()
	
	local x, y, w, h = self.x, self.y, self.w, self.h
	
	self.buff = GUI.GetBuffer()
	
	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2*w, h)
	
	GUI.color("elm_bg")
	gfx.rect(0, 0, 2*w, h, 1)
	
	GUI.color("elm_frame")
	gfx.rect(0, 0, w, h, 0)
	
	GUI.color("elm_fill")
	gfx.rect(w, 0, w, h, 0)
	gfx.rect(w + 1, 1, w - 2, h - 2, 0)
	
	
end


-- Textbox - Draw.
function GUI.Textbox:draw()
	
	
	local x, y, w, h = self.x, self.y, self.w, self.h
	
	local caption = self.caption
	local caret = self.caret
	local sel = self.sel
	local text = self.retval
	local focus = self.focus
	local pad = self.pad
	
	-- Draw the caption
	GUI.font(self.font_a)
	local str_w, str_h = gfx.measurestr(caption)
	gfx.x = x - str_w - pad
	gfx.y = y + (h - str_h) / 2
	GUI.text_bg(caption, self.bg)
	
	if self.shadow then 
		GUI.shadow(caption, self.color, "shadow") 
	else
		GUI.color(self.color)
		gfx.drawstr(caption)
	end
	
	-- Draw the textbox frame, and make it brighter if focused.
--[[	
	GUI.color("elm_bg")
	gfx.rect(x, y, w, h, 1)
	
	if focus then 
				
		GUI.color("elm_fill")
		gfx.rect(x + 1, y + 1, w - 2, h - 2, 0)
		
	else
		
		-- clear the selection while we're here
		sel = 0
		
		GUI.color("elm_frame")
	end

	gfx.rect(x, y, w, h, 0)
]]--

	gfx.blit(self.buff, 1, 0, (focus and w or 0), 0, w, h, x, y)

	-- Draw the text
	GUI.color(self.color)
	GUI.font(self.font_b)
	str_w, str_h = gfx.measurestr(text)
	gfx.x = x + pad
	gfx.y = y + (h - str_h) / 2
	gfx.drawstr(text)
	
	
	
	-- Is any text selected?
	if focus then
		
		if sel ~= 0 then
	
			-- Use the caret and selection positions to figure out the dimensions
			local sel_start, sel_end = caret, caret + sel
			if sel_start > sel_end then sel_start, sel_end = sel_end, sel_start end
			local x_start = gfx.measurestr(string.sub(text, 0, sel_start))
			
			
			local w_sel = gfx.measurestr(string.sub(text, sel_start + 1, sel_end))
			
			
			-- Draw the selection highlight
			GUI.color("txt")
			gfx.rect(x + x_start + pad, y + 4, w_sel, h - 8, 1)
			
			-- Draw the selected text
			GUI.color("wnd_bg")
			gfx.x, gfx.y = x + x_start + pad, y + (h - str_h) / 2
			gfx.drawstr(string.sub(text, sel_start + 1, sel_end))
			
		end

		-- Show the editing caret for half of the blink cycle
		if self.show_caret then
			
			local caret_x = x + pad + gfx.measurestr(string.sub(text, 0, caret))

			GUI.color("txt")
			gfx.rect(caret_x, y + 4, 2, h - 8)
			
		end
		
	--GUI.redraw_z[self.z] = true
		
	end
	
end


-- Textbox - Get/set value
function GUI.Textbox:val(newval)
	
	if newval then
		self.retval = newval
		GUI.redraw_z[self.z] = true		
	else
		return self.retval
	end
end


-- Textbox - Lost focus
function GUI.Textbox:lostfocus()

	GUI.redraw_z[self.z] = true
	
end

-- Textbox - Get the closest character position to the mouse.
function GUI.Textbox:getcaret()
	
	local len = string.len(self.retval)
	GUI.font(self.font_b)
	
	for i = 1, len do
		
		w = gfx.measurestr(string.sub(self.retval, 1, i))
		if GUI.mouse.x < (self.x + self.pad + w) then return i - 1 end
	
	end
	
	return len

end


-- Textbox - Mouse down.
function GUI.Textbox:onmousedown()
	
	local x, y = GUI.mouse.x, GUI.mouse.y
	
	-- Was the mouse clicked inside this element?
	--self.focus = GUI.IsInside(self, x, y)
	if self.focus then
		
		-- Place the caret on the nearest character and reset the blink cycle
		self.caret = self:getcaret()
		self.cursstate = 0
		self.sel = 0
		self.caret = self:getcaret()
		GUI.redraw_z[self.z] = true
	end
	
end


-- Textbox - Double-click.
function GUI.Textbox:ondoubleclick()
	
	local len = string.len(self.retval)
	self.caret, self.sel = len, -len
	GUI.redraw_z[self.z] = true
end


-- Textbox - Mouse drag.
function GUI.Textbox:ondrag()
	
	self.sel = self:getcaret() - self.caret
	GUI.redraw_z[self.z] = true	
end


-- Textbox - Typing.
function GUI.Textbox:ontype()

	GUI.font(3)
	
	local char = GUI.char
	local caret = self.caret
	local text = self.retval
	local maxlen = gfx.measurestr(text) >= (self.w - (self.pad * 3))
	

	-- Is there text selected?
	if self.sel ~= 0 then
		
		-- Delete the selected text
		local sel_start, sel_end = caret, caret + self.sel
		if sel_start > sel_end then sel_start, sel_end = sel_end, sel_start end
		
		text = string.sub(text, 0, sel_start)..string.sub(text, sel_end + 1)
		
		self.caret = sel_start
		
	end
		

	if char		== GUI.chars.LEFT then
		if caret > 0 then self.caret = caret - 1 end

	elseif char	== GUI.chars.RIGHT then
		if caret < string.len(text) then self.caret = caret + 1 end
	
	elseif char == GUI.chars.BACKSPACE then
		if string.len(text) > 0 and self.sel == 0 and caret > 0 then
			text = string.sub(text, 1, caret - 1)..(string.sub(text, caret + 1))
			self.caret = caret - 1
		end
		
	elseif char == GUI.chars.DELETE then
		if string.len(text) > 0 and self.sel == 0 then
				text = string.sub(text, 1, caret)..(string.sub(text, caret + 2))
		end
		
	elseif char == GUI.chars.RETURN then
		self.focus = false
		self:lostfocus()
		text = self.retval
		
	elseif char == GUI.chars.HOME then
		self.caret = 0
		
	elseif char == GUI.chars.END then
		self.caret = string.len(text)		
	
	-- Any other valid character, as long as we haven't filled up the textbox
	elseif char >= 32 and char <= 255 and maxlen == false then

		-- Insert the typed character at the caret position
		text = string.format("%s%c%s", string.sub(text, 1, caret), char, string.sub(text, caret + 1))
		self.caret = self.caret + 1
		
	end
	
	self.retval = text
	self.sel = 0
	GUI.redraw_z[self.z] = true	
end


-- Textbox - On Update (for making it blink)
function GUI.Textbox:onupdate()
	
	if self.focus then
	
		if self.blink == 0 then
			self.show_caret = true
			GUI.redraw_z[self.z] = true
		elseif self.blink == math.floor(GUI.txt_blink_rate / 2) then
			self.show_caret = false
			GUI.redraw_z[self.z] = true
		end
		self.blink = (self.blink + 1) % GUI.txt_blink_rate

	end
	
end



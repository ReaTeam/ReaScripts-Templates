--[[	Lokasenna_GUI - TextEditor class
	
	---- User parameters ----

	(name, z, x, y, w, h[, text, caption, pad])

Required:
z				Element depth, used for hiding and disabling layers. 1 is the highest.
x, y			Coordinates of top-left corner
w, h			Width and height of the text editor

Optional:
text			Multiline string of text
caption			Label shown to the left of the text editor
pad				Padding between the label and the text editor


Additional:
bg				Color to be drawn underneath the label. Defaults to "wnd_bg"
shadow			Boolean. Draw a shadow beneath the label?
color			Text color
font_a			Label font

font_b			Text font. 
				*** Only monospaced fonts will work properly ***

focus			Whether the text editor is "in focus" or not, allowing users to type.
				This setting is automatically updated, so you shouldn't need to
				change it yourself in most cases.
				

Extra methods:

GUI.Val()		Returns self.retval as a string
GUI.Val(new)	Accepts a multiline string

:wnd_recalc()	If your script needs to resize the text editor, move it around, etc,
				run this afterward so it can update a few internal values


]]--

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end


GUI.fonts.texteditor = {"Courier", 10}


-- TextEditor - New
GUI.TextEditor = GUI.Element:new()
function GUI.TextEditor:new(name, z, x, y, w, h, text, caption, pad)
	
	local txt = {}
	
	txt.name = name
	txt.type = "TextEditor"
	
	txt.z = z
	GUI.redraw_z[z] = true	
	
	txt.x, txt.y, txt.w, txt.h = x, y, w, h

	txt.retval = text or {}
	txt.undo_states = {}
	txt.redo_states = {}
	txt.caption = caption or ""
	txt.pad = pad or 4
	
	txt.shadow = true
	txt.bg = "elm_bg"
	txt.color = "txt"
	txt.blink = 0
	
	-- Scrollbar fill
	txt.col_fill = "elm_fill"
	
	txt.font_a = 3
	
	-- Forcing a safe monospace font to make our lives easier
	txt.font_b = "texteditor"
	
	txt.wnd_pos = {x = 0, y = 1}
	txt.caret = {x = 0, y = 1}

	txt.char_h, txt.wnd_h, txt.wnd_w, txt.char_w = nil, nil, nil, nil

	txt.focus = false
		
	setmetatable(txt, self)
	self.__index = self
	return txt

end


function GUI.TextEditor:init()
	
	-- Process the initial string; split it into a table by line
	if type(self.retval) == "string" then self:val(self.retval) end
	
	local x, y, w, h = self.x, self.y, self.w, self.h
	
	self.buff = GUI.GetBuffer()
	
	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2*w, h)
	
	GUI.color(self.bg)
	gfx.rect(0, 0, 2*w, h, 1)
	
	GUI.color("elm_frame")
	gfx.rect(0, 0, w, h, 0)
	
	GUI.color("elm_fill")
	gfx.rect(w, 0, w, h, 0)
	gfx.rect(w + 1, 1, w - 2, h - 2, 0)
	
	
end


-- TextEditor - Draw.
function GUI.TextEditor:draw()
	
	
	local x, y, w, h = self.x, self.y, self.w, self.h
	
	local caption = self.caption
	local caret = self.caret
	local focus = self.focus
	local pad = self.pad

	-- Some values can't be set in :init() because the window isn't
	-- open yet - measurements won't work.
	if not self.wnd_h then self:wnd_recalc() end
	
	-- Draw the caption
	if caption and caption ~= "" then self:drawcaption() end
	
	-- Draw the background + frame
	gfx.blit(self.buff, 1, 0, (focus and w or 0), 0, w, h, x, y)

	-- Draw the text
	self:drawtext()
	
	-- Caret
	-- Only needs to be drawn for half of the blink cycle
	if focus and self.show_caret then self:drawcaret() end

	-- Selection
	if self.sel_s and self.sel_e then
		
		self:drawselection()
		
	end

	-- Scrollbars
	self:drawscrollbars()

end


-- TextEditor - Get/set value
function GUI.TextEditor:val(newval)
	
	if newval then
		self.retval = self:stringtotable(newval)
		self:clearselection()
		GUI.redraw_z[self.z] = true		
	else
		return table.concat(self.retval, "\n")
	end
	
end


-- Make the caret blink, if focused
function GUI.TextEditor:onupdate()

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


function GUI.TextEditor:lostfocus()

	GUI.redraw_z[self.z] = true
	
end


-----------------------------------
-------- Input methods ------------
-----------------------------------


function GUI.TextEditor:onmousedown(scroll)



	-- If over the scrollbar, or we came from :ondrag with an origin point
	-- that was over the scrollbar...
	local scroll = scroll or self:overscrollbar()
	if scroll then
		
		-- Vertical scroll
		if scroll == "v" then
			
			local len = self:getwndlength()
			local wnd_c = GUI.round( ((GUI.mouse.y - self.y) / self.h) * len  )
			self.wnd_pos.y = GUI.round(
								GUI.clamp(	1, 
											wnd_c - (self.wnd_h / 2), 
											len - self.wnd_h + 1
										)
										)
										
		-- Horizontal scroll	
		else
			
			local len = self:getmaxwidth()
			local wnd_c = GUI.round( ((GUI.mouse.x - self.x) / self.w) * len   )
			self.wnd_pos.x = GUI.round(
								GUI.clamp(	0,
											wnd_c - (self.wnd_w / 2),
											len - self.wnd_w
										)
										)
				
		end
		
		GUI.redraw_z[self.z] = true
	
	-- Shift+click to select text
	elseif GUI.mouse.cap & 8 == 8 and self.caret then
			
			self.sel_s = {x = self.caret.x, y = self.caret.y}
			self.caret = self:getcaret(GUI.mouse.x, GUI.mouse.y)
			self.sel_e = {x = self.caret.x, y = self.caret.y}
	
	-- Place the caret
	else
	
		self.caret = self:getcaret(GUI.mouse.x, GUI.mouse.y)
		self:clearselection()
	
	end
	
end


function GUI.TextEditor:ondoubleclick()
	
	
	self:selectword()
	
end


function GUI.TextEditor:ondrag()
	
	local scroll = self:overscrollbar(GUI.mouse.ox, GUI.mouse.oy)
	if scroll then 
		
		self:onmousedown(scroll)
		
	-- Select from where the mouse is now to where it started
	else
	
		self.sel_s = self:getcaret(GUI.mouse.ox, GUI.mouse.oy)		
		self.sel_e = self:getcaret(GUI.mouse.x, GUI.mouse.y)

	end
	
	GUI.redraw_z[self.z] = true
	
end


function GUI.TextEditor:ontype()

	-- Non-typeable / navigation chars
	if self.keys[GUI.char] then
		
		local shift = GUI.mouse.cap & 8 == 8
		
		if shift and not self.sel_s then 
			self.sel_s = {x = self.caret.x, y = self.caret.y}
		end
		
		-- Flag for some keys (clipboard shortcuts) to skip
		-- the next section
		local bypass = self.keys[GUI.char](self)
		
		if shift and GUI.char ~= (GUI.chars.BACKSPACE) then
			
			self.sel_e = {x = self.caret.x, y = self.caret.y}
			
		elseif not bypass then
		
			self:clearselection()
			
		end

	-- Typeable chars
	elseif GUI.clamp(32, GUI.char, 254) == GUI.char then
		
		if self.sel_s then self:deleteselection() end
		
		self:insertchar(GUI.char)
		self:clearselection()
	
		
	end
	self:windowtocaret()
	
	-- Reset the caret so the visual change isn't laggy
	self.blink = 0

end


function GUI.TextEditor:onwheel(inc)
	
	-- Ctrl -- maybe zoom?
	if GUI.mouse.cap & 4 == 4 then
	
		--[[ Buggy, disabled for now
		local font = self.font_b
		font = 	(type(font) == "string" and GUI.fonts[font])
			or	(type(font) == "table" and font)
			
		if not font then return end
		
		local dir = inc > 0 and 4 or -4
		
		font[2] = GUI.clamp(8, font[2] + dir, 30)
		
		self.font_b = font
		
		self:wnd_recalc()
		]]--
	
	-- Shift -- Horizontal scroll
	elseif GUI.mouse.cap & 8 == 8 then
	
		local len = self:getmaxwidth()
		
		if len <= self.wnd_w then return end

		-- Scroll right/left
		local dir = inc > 0 and 3 or -3
		self.wnd_pos.x = GUI.clamp(0, self.wnd_pos.x + dir, len - self.wnd_w)
	
	-- Vertical scroll
	else
	
		local len = self:getwndlength()
	
		if len <= self.wnd_h then return end

		-- Scroll up/down
		local dir = inc > 0 and -3 or 3
		self.wnd_pos.y = GUI.clamp(1, self.wnd_pos.y + dir, len - self.wnd_h)
		
	end
	
	GUI.redraw_z[self.z] = true
	
end


------------------------------------
-------- Drawing methods -----------
------------------------------------


function GUI.TextEditor:drawcaption()
		
	local str = self.caption
	
	GUI.font(self.font_a)
	local str_w, str_h = gfx.measurestr(str)
	gfx.x = self.x - str_w - self.pad
	gfx.y = self.y + self.pad
	GUI.text_bg(str, self.bg)
	
	if self.shadow then 
		GUI.shadow(str, self.color, "shadow") 
	else
		GUI.color(self.color)
		gfx.drawstr(str)
	end
	
end


function GUI.TextEditor:drawtext()
	
	GUI.color(self.color)
	GUI.font(self.font_b)
	
	local tmp = {}
	for i = self.wnd_pos.y, math.min(self:wnd_bottom() - 1, #self.retval) do
		
		local str = tostring(self.retval[i]) or ""
		tmp[#tmp + 1] = string.sub(str, self.wnd_pos.x + 1, self:wnd_right() - 1)
		
	end

	gfx.x, gfx.y = self.x + self.pad, self.y + self.pad
	gfx.drawstr( table.concat(tmp, "\n") )

end


function GUI.TextEditor:drawcaret()
	
	local caret_wnd = self:adjusttowindow(self.caret)

	if caret_wnd.x and caret_wnd.y then
		
		GUI.color("txt")
		
		gfx.rect(	self.x + self.pad + (caret_wnd.x * self.char_w), 
					self.y + self.pad + (caret_wnd.y * self.char_h), 
					self.insert_caret and self.char_w or 2, 
					self.char_h - 2)
		
	end
		
end


function GUI.TextEditor:drawselection()
	
	local off_x, off_y = self.x + self.pad, self.y + self.pad
	local x, y, w, h
		
	GUI.color("elm_fill")
	gfx.a = 0.5
	gfx.mode = 1
	
	-- Get all the selection boxes that need to be drawn
	local coords = self:checkselection()	
	
	for i = 1, #coords do
	
		-- Make sure at least part of this line is visible
		if self:selectionvisible(coords[i]) then 
			
			-- Convert from char/row coords to actual pixels
			x, y =	off_x + (coords[i].x - self.wnd_pos.x) * self.char_w,
					off_y + (coords[i].y - self.wnd_pos.y) * self.char_h
							
									-- Really kludgy, but it fixes a weird issue
									-- where wnd_pos.x > 0 was drawing all the widths
									-- one character too short
			w =		(coords[i].w + (self.wnd_pos.x > 0 and 1 or 0)) * self.char_w
			
			-- Keep the selection from spilling out past the scrollbar
			w = math.min(w, self.x + self.w - x - self.pad)
			
			h =	self.char_h
		
			gfx.rect(x, y, w, h, true)

		end

	end
	
	gfx.mode = 0
	
	-- Later calls to GUI.color should handle this, but for
	-- some reason they aren't always.
	gfx.a = 1
	
end


function GUI.TextEditor:drawscrollbars()

	-- Do we need to be here?
	local max_w = self:getmaxwidth()
	local vert, horz = 	self:getwndlength() > self.wnd_h,
						max_w > self.wnd_w
	if not (vert or horz) then return end

	local x, y, w, h = self.x, self.y, self.w, self.h
	local vx, vy, vw, vh = x + w - 8 - 4, y + 4, 8, h - 16
	local hx, hy, hw, hh = x + 4, y + h - 8 - 4, w - 16, 8
	local fade_w = 15
	local _
	
	-- Draw a gradient to fade out the last ~16px of text
	GUI.color("elm_bg")
	for i = 0, fade_w do
		
		gfx.a = i/fade_w
		
		if vert then
			
			gfx.line(vx + i - fade_w, y + 2, vx + i - fade_w, y + h - 4)
			
			-- Fade out the top if we're not at wnd_pos.y = 1
			_ = self.wnd_pos.y > 1 and
				gfx.line(x + 2, y + 2 + fade_w - i, x + w - 4, y + 2 + fade_w - i)
				
		end
				
		if horz then
			
			gfx.line(x + 2, hy + i - fade_w, x + w - 4, hy + i - fade_w)
			
			-- Fade out the left if we're not at wnd_pos.x = 0
			_ = self.wnd_pos.x > 0 and
				gfx.line(x + 2 + fade_w - i, y + 2, x + 2 + fade_w - i, y + h - 4)
				
		end
		
	end	
	
	_ = vert and gfx.rect(vx, y + 2, vw + 2, h - 4, true)
	_ = horz and gfx.rect(x + 2, hy, w - 4, hh + 2, true)
	
	-- Draw slider track
	GUI.color("tab_bg")
	_ = vert and GUI.roundrect(vx, vy, vw, vh, 4, 1, 1)
	_ = horz and GUI.roundrect(hx, hy, hw, hh, 4, 1, 1)
	GUI.color("elm_outline")
	_ = vert and GUI.roundrect(vx, vy, vw, vh, 4, 1, 0)
	_ = horz and GUI.roundrect(hx, hy, hw, hh, 4, 1, 0)
		
	-- Draw slider fill
	GUI.color(self.col_fill)	
	
	local fx, fy, fw, fh
	
	if vert then
		fh = (self.wnd_h / self:getwndlength()) * vh - 4
		if fh < 4 then fh = 4 end
		fy = vy + ((self.wnd_pos.y - 1) / self:getwndlength()) * vh + 2
		
		GUI.roundrect(vx + 2, fy, vw - 4, fh, 2, 1, 1)
	end
	
	if horz then
		fw = (self.wnd_w / max_w) * hw - 4
		if fw < 4 then fw = 4 end
		fx = hx + (self.wnd_pos.x / max_w) * hw + 2
		
		GUI.roundrect(fx, hy + 2, fw, hh - 4, 2, 1, 1)
	end
	
		
end


------------------------------------
-------- Selection methods ---------
------------------------------------


-- Figure out what portion of the selection, if any, needs to be drawn
function GUI.TextEditor:checkselection()

	local sx, sy = self.sel_s.x, self.sel_s.y
	local ex, ey = self.sel_e.x, self.sel_e.y
	
	-- Make sure the Start is before the End
	if sy > ey then
		sx, sy, ex, ey = ex, ey, sx, sy
	elseif sy == ey and sx > ex then
		sx, ex = ex, sx
	end

	local x, w
	local sel_coords = {}
	
	local function insert_coords(x, y, w)
		table.insert(sel_coords, {x = x, y = y, w = w})
	end
	
	-- Eliminate the easiest case - start and end are the same line
	if sy == ey then
		
		x = GUI.clamp(self.wnd_pos.x, sx, self:wnd_right())
		w = GUI.clamp(x, ex, self:wnd_right()) - x

		insert_coords(x, sy, w)
		

	-- ...fine, we'll do it the hard way
	else

		-- Start	
		x = GUI.clamp(self.wnd_pos.x, sx, self:wnd_right())
		w = math.min(self:wnd_right(), #(self.retval[sy] or "")) - x
			
		insert_coords(x, sy, w)
			
		
		-- Any intermediate lines are clearly full
		for i = self.wnd_pos.y, self:wnd_bottom() - 1 do
			
			x, w = nil, nil
			
			-- Is this line within the selection?
			if i > sy and i < ey then
				
				w = math.min(self:wnd_right(), #(self.retval[i] or "")) - self.wnd_pos.x
				insert_coords(self.wnd_pos.x, i, w)

			-- We're past the selection
			elseif i >= ey then
			
				break
				
			end
			
		end
	
	
		-- End
		x = self.wnd_pos.x
		w = math.min(self:wnd_right(), ex) - self.wnd_pos.x
		insert_coords(x, ey, w)
		
		
	end
	
	return sel_coords
	

end


-- Make sure at least part of this selection block is within the window
function GUI.TextEditor:selectionvisible(coords)

	return 		coords.w > 0 
			and coords.x + coords.w > self.wnd_pos.x 
			and coords.y >= self.wnd_pos.y 
			and coords.y < self:wnd_bottom()

end


function GUI.TextEditor:selectall()
	
	self.sel_s = {x = 0, y = 1}
	self.caret = {x = 0, y = 1}
	self.sel_e = {	x = string.len(self.retval[#self.retval]),
					y = #self.retval}
	
	
end


function GUI.TextEditor:selectword()
	
	local str = self.retval[self.caret.y] or ""

	if not str or str == "" then return 0 end
	
	local sx = string.find( str:sub(1, self.caret.x), "%s[%S]+$") or 0
	
	local ex =	(	string.find( str, "%s", sx + 1)
			or		string.len(str) + 1 )
				- (self.wnd_pos.x > 0 and 2 or 1)	-- Kludge, fixes length issues

	self.sel_s = {x = sx, y = self.caret.y}
	self.sel_e = {x = ex, y = self.caret.y}	
	
end


function GUI.TextEditor:clearselection()

	self.sel_s = nil
	self.sel_e = nil
	
end


function GUI.TextEditor:deleteselection()
	
	if not (self.sel_s and self.sel_e) then return 0 end
	
	local sx, sy, ex, ey = self.sel_s.x, self.sel_s.y, self.sel_e.x, self.sel_e.y

	self:setundostate()

	-- Make sure the Start is before the End
	if sy > ey then
		sx, sy, ex, ey = ex, ey, sx, sy
	elseif sy == ey and sx > ex then
		sx, ex = ex, sx
	end	
	
	-- Easiest case; single line
	if sy == ey then
		
		self.retval[sy] = string.sub(self.retval[sy] or "", 1, sx)..string.sub(self.retval[sy] or "", ex + 1)
		
	else
	
		self.retval[sy] = string.sub(self.retval[sy] or "", 1, sx)..string.sub(self.retval[ey] or "", ex + 1)
		for i = sy + 1, ey do
			table.remove(self.retval, sy + 1)
		end
		
	end
	
	self.caret.x, self.caret.y = sx, sy
	
	self:clearselection()
	self:windowtocaret()
	
end


function GUI.TextEditor:getselection()

	local sx, sy, ex, ey = self.sel_s.x, self.sel_s.y, self.sel_e.x, self.sel_e.y
	
	-- Make sure the Start is before the End
	if sy > ey then
		sx, sy, ex, ey = ex, ey, sx, sy
	elseif sy == ey and sx > ex then
		sx, ex = ex, sx
	end

	local tmp = {}
	
	for i = 0, ey - sy do
	
		tmp[i + 1] = self.retval[sy + i]
		
	end
	
	tmp[1] = string.sub(tmp[1], sx + 1)
	tmp[#tmp] = string.sub(tmp[#tmp], 1, ex - (sy == ey and sx or 0))
	
	return table.concat(tmp, "\n")	
	
end


------------------------------------
-------- Window/Pos Helpers --------
------------------------------------


-- Updates internal values for the window size
function GUI.TextEditor:wnd_recalc()
	
	GUI.font(self.font_b)
	
	self.char_h = gfx.texth
	self.wnd_h = math.floor((self.h - 2*self.pad) / self.char_h)
	self.char_w = gfx.measurestr("_")
	self.wnd_w = math.floor(self.w / self.char_w)	
	
end


-- Get the right edge of the window (in chars)
function GUI.TextEditor:wnd_right()
	
	return self.wnd_pos.x + self.wnd_w
	
end


-- Get the bottom edge of the window (in rows)
function GUI.TextEditor:wnd_bottom()
	
	return self.wnd_pos.y + self.wnd_h
	
end


-- Get the length of the longest line
function GUI.TextEditor:getmaxwidth()
	
	local w = 0
	
	-- Slightly faster because we don't care about order
	for k, v in pairs(self.retval) do
		w = math.max(w, string.len(v))
	end
	
	-- Pad the window out a little
	return w + 2
	
end


-- Add 1 to the table length so the horizontal scrollbar is never in the way
function GUI.TextEditor:getwndlength()
	
	return #self.retval + 2
	
end


-- See if a given pair of coords is in the visible window
-- If so, adjust them from absolute to window-relative
-- If not, returns nil
function GUI.TextEditor:adjusttowindow(coords)

	local x, y = coords.x, coords.y
	x = (GUI.clamp(self.wnd_pos.x, x, self:wnd_right() - 3) == x)
						and x - self.wnd_pos.x
						or nil

	-- Fixes an issue with the position being one space to the left of where it should be 
	-- when the window isn't at x = 0. Not sure why.
	--x = x and (x + (self.wnd_pos.x == 0 and 0 or 1))

	y = (GUI.clamp(self.wnd_pos.y, y, self:wnd_bottom() - 1) == y)
						and y - self.wnd_pos.y
						or nil

	return {x = x, y = y}
	
end


-- Adjust the window if the caret has been moved off-screen
function GUI.TextEditor:windowtocaret()
	
	-- Horizontal
	if self.caret.x < self.wnd_pos.x + 4 then
		self.wnd_pos.x = math.max(0, self.caret.x - 4)
	elseif self.caret.x > (self:wnd_right() - 4) then
		self.wnd_pos.x = self.caret.x + 4 - self.wnd_w
	end
	
	-- Vertical
	local bot = self:wnd_bottom()
	local adj = (	(self.caret.y < self.wnd_pos.y) and -1	)
			or	(	(self.caret.y >= bot) and 1	)
			or	(	(bot > self:getwndlength() and -(bot - self:getwndlength() - 1) ) )
	
	if adj then self.wnd_pos.y = GUI.clamp(1, self.wnd_pos.y + adj, self.caret.y) end
	
end


-- TextEditor - Get the closest character position to the given coords.
function GUI.TextEditor:getcaret(x, y)

	local tmp = {}	
		
	tmp.x = math.floor(		((x - self.x) / self.w ) * self.wnd_w) + self.wnd_pos.x
	tmp.y = math.floor(		(y - (self.y + self.pad)) 
						/	self.char_h)
			+ self.wnd_pos.y

	tmp.y = GUI.clamp(1, tmp.y, #self.retval + 1)
	tmp.x = GUI.clamp(0, tmp.x, #(self.retval[tmp.y] or ""))

	return tmp
			
end


-- Is the mouse over either of the scrollbars?
-- Returns "h", "v", or false
function GUI.TextEditor:overscrollbar(x, y)
	
	if	self:getwndlength() > self.wnd_h 
	and (x or GUI.mouse.x) >= (self.x + self.w - 12) then
		
		return "v"
		
	elseif 	self:getmaxwidth() > self.wnd_w
	and		(y or GUI.mouse.y) >= (self.y + self.h - 12) then
	
		return "h"
		
	end
	
end


------------------------------------
-------- Char/String Helpers -------
------------------------------------


-- Split a string by line into a table
function GUI.TextEditor:stringtotable(str)
	
	local tmp = {}
	for line in string.gmatch(str, "([^\r\n]*)[\r\n]?") do
		table.insert(tmp, line)
	end
	
	return tmp	
	
end


-- Insert a string at the caret, deleting any existing selection
-- i.e. Paste
function GUI.TextEditor:insertstring(str, move_caret)
	
	local sx, sy = 	(self.sel_s and self.sel_s.x or self.caret.x), 
					(self.sel_s and self.sel_s.y or self.caret.y)

	self:setundostate()

	if self.sel_s then 
		self:deleteselection()
		sx, sy = self.caret.x, self.caret.y
	end
	
	local tmp = self:stringtotable(str)
	
	local pre, post =	string.sub(self.retval[sy] or "", 1, sx),
						string.sub(self.retval[sy] or "", sx + 1)
	
	if #tmp == 1 then
		
		self.retval[sy] = pre..tmp[1]..post
		if move_caret then self.caret.x = self.caret.x + #tmp[1] end
		
	else				

		self.retval[sy] = tostring(pre)..tmp[1]
		table.insert(self.retval, sy + 1, tmp[#tmp]..tostring(post))
		for i = 2, #tmp - 1 do
			table.insert(self.retval, sy + 1, tmp[i])
		end
		
		if move_caret then
			self.caret = {	x =	string.len(tmp[#tmp]),
							y =	self.caret.y + #tmp - 1}
		end

	end

end


-- Insert typeable characters
function GUI.TextEditor:insertchar(char)

	self:setundostate()
	
	local str = self.retval[self.caret.y] or ""
	local a, b = str:sub(1, self.caret.x), str:sub(self.caret.x + (self.insert_caret and 2 or 1))
	self.retval[self.caret.y] = a..string.char(char)..b
	self.caret.x = self.caret.x + 1
	
end


-- Place the caret at the end of the current line
function GUI.TextEditor:carettoend()
		
	return #(self.retval[self.caret.y] or "") > 0
		and #self.retval[self.caret.y]
		or 0
	
end


-- Non-typing key commands
-- A table of functions is more efficient to access than using really
-- long if/then/else structures.
GUI.TextEditor.keys = {
	
	[GUI.chars.LEFT] = function(self)
		
		if self.caret.x < 1 and self.caret.y > 1 then
			self.caret.y = self.caret.y - 1
			self.caret.x = self:carettoend()
		else
			self.caret.x = math.max(self.caret.x - 1, 0)
		end
		
	end,
	
	[GUI.chars.RIGHT] = function(self)
		
		if self.caret.x == self:carettoend() and self.caret.y < self:getwndlength() then
			self.caret.y = self.caret.y + 1
			self.caret.x = 0
		else
			self.caret.x = math.min(self.caret.x + 1, self:carettoend() )
		end

	end,
	
	[GUI.chars.UP] = function(self)
		
		if self.caret.y == 1 then
			self.caret.x = 0	
		else
			self.caret.y = math.max(1, self.caret.y - 1)
			self.caret.x = math.min(self.caret.x, self:carettoend() )
		end
		
	end,
	
	[GUI.chars.DOWN] = function(self)
		
		if self.caret.y == self:getwndlength() then
			self.caret.x = string.len(self.retval[#self.retval])
		else
			self.caret.y = math.min(self.caret.y + 1, #self.retval)
			self.caret.x = math.min(self.caret.x, self:carettoend() )
		end
		
	end,
	
	[GUI.chars.HOME] = function(self)
		
		self.caret.x = 0
		
	end,
	
	[GUI.chars.END] = function(self)
		
		self.caret.x = self:carettoend()
		
	end,
	
	[GUI.chars.PGUP] = function(self)

		local caret_off = self.caret and (self.caret.y - self.wnd_pos.y)
		
		self.wnd_pos.y = math.max(1, self.wnd_pos.y - self.wnd_h)
		
		if caret_off then
			self.caret.y = self.wnd_pos.y + caret_off
			self.caret.x = math.min(self.caret.x, string.len(self.retval[self.caret.y]))
		end
		
	end,
	
	[GUI.chars.PGDN] = function(self)

		local caret_off = self.caret and (self.caret.y - self.wnd_pos.y)
		
		self.wnd_pos.y = GUI.clamp(1, self:getwndlength() - self.wnd_h + 1, self.wnd_pos.y + self.wnd_h)

		if caret_off then
			self.caret.y = self.wnd_pos.y + caret_off
			self.caret.x = math.min(self.caret.x, string.len(self.retval[self.caret.y]))
		end
		
	end,
	
	
	[GUI.chars.BACKSPACE] = function(self)
	
		self:setundostate()		
	
		-- Is there a selection?
		if self.sel_s and self.sel_e then
			
			self:deleteselection()	
		
		-- If we have something to backspace, delete it
		elseif self.caret.x > 0 then
			
			local str = self.retval[self.caret.y]
			self.retval[self.caret.y] = str:sub(1, self.caret.x - 1)..str:sub(self.caret.x + 1, -1)
			self.caret.x = self.caret.x - 1
		
		-- Beginning of the line; backspace the contents to the prev. line
		elseif self.caret.x == 0 and self.caret.y > 1 then
			
			self.caret.x = #self.retval[self.caret.y - 1]
			self.retval[self.caret.y - 1] = self.retval[self.caret.y - 1] .. (self.retval[self.caret.y] or "")
			table.remove(self.retval, self.caret.y)
			self.caret.y = self.caret.y - 1
			
		end
		
	end,
	
	[GUI.chars.INSERT] = function(self)
		
		self.insert_caret = not self.insert_caret
		
	end,
	
	[GUI.chars.DELETE] = function(self)
		
		self:setundostate()

		-- Is there a selection?
		if self.sel_s then

			self:deleteselection()
		
		-- Deleting on the current line
		elseif self.caret.x < self:carettoend() then
		
			local str = self.retval[self.caret.y] or ""
			self.retval[self.caret.y] = str:sub(1, self.caret.x) .. str:sub(self.caret.x + 2)
		
		elseif self.caret.y < self:getwndlength() then
		
			self.retval[self.caret.y] = self.retval[self.caret.y] .. (self.retval[self.caret.y + 1] or "")
			table.remove(self.retval, self.caret.y + 1)
			
		end

	end,
	
	[GUI.chars.RETURN] = function(self)
		
		self:setundostate()

		if sel_s then self:deleteselection() end
		
		local str = self.retval[self.caret.y] or ""
		self.retval[self.caret.y] = str:sub(1, self.caret.x)
		table.insert(self.retval, self.caret.y + 1, str:sub(self.caret.x + 1) )
		self.caret.y = self.caret.y + 1
		self.caret.x = 0
		
	end,

	-- A -- Select All
	[1] = function(self)
		
		if GUI.mouse.cap & 4 == 4 then
			
			self:selectall()
			
			-- Flag to bypass the "clear selection" logic in :ontype()
			return true	
			
		else
			self:insertchar(GUI.char)
		end
		
	end,
	
	-- C -- Copy
	[3] = function(self)
		
		if GUI.mouse.cap & 4 == 4 then
			
			if self.sel_s and self:SWS_clipboard() then
				
				local str = self:getselection()
				reaper.CF_SetClipboard(str)
				
			end
					
			-- Flag to bypass the "clear selection" logic in :ontype()		
			return true			
			
		else
			self:insertchar(GUI.char)
		end
		
	end,
	
	-- V -- Paste
	[22] = function(self)
		
		if GUI.mouse.cap & 4 == 4 then
	
			if self:SWS_clipboard() then
				
				-- reaper.SNM_CreateFastString( str )
				-- reaper.CF_GetClipboardBig( output )
				local fast_str = reaper.SNM_CreateFastString("")
				local str = reaper.CF_GetClipboardBig(fast_str)
				reaper.SNM_DeleteFastString(fast_str)
				
				self:insertstring(str, true)

			end
		
			-- Flag to bypass the "clear selection" logic in :ontype()		
			return true
			
		else
			self:insertchar(GUI.char)
		end	
		
	end,
	
	-- X -- Cut
	[24] = function(self)
	
		if GUI.mouse.cap & 4 == 4 then
			
			if self.sel_s and self:SWS_clipboard() then
				
				local str = self:getselection()
				reaper.CF_SetClipboard(str)
				self:deleteselection()
				
			end
		
			-- Flag to bypass the "clear selection" logic in :ontype()		
			return true		
	
		else
			self:insertchar(GUI.char)
		end
		
	end,	
	
	-- Y -- Redo
	[25] = function (self)
		
		if GUI.mouse.cap & 4 == 4 then 
			
			self:redo() 
			
		else
		
			self:insertchar(GUI.char)
			
		end
		
	end,
	
	-- Z -- Undo
	[26] = function (self)
		
		if GUI.mouse.cap & 4 == 4 then 
			
			self:undo()
			
		else
			self:insertchar(GUI.char)
		end		
		
	end
}


------------------------------------
-------- Misc. Functions -----------
------------------------------------


function GUI.TextEditor:undo()
	
	if #self.undo_states == 0 then return end
	table.insert(self.redo_states, self:geteditorstate() )
	local state = table.remove(self.undo_states)

	self.retval = state.retval
	self.caret = state.caret
	
	self:windowtocaret()
	
end


function GUI.TextEditor:redo()
	
	if #self.redo_states == 0 then return end
	table.insert(self.undo_states, self:geteditorstate() )
	local state = table.remove(self.redo_states)
	self.retval = state.retval
	self.caret = state.caret
	
	self:windowtocaret()
	
end


function GUI.TextEditor:setundostate()

	table.insert(self.undo_states, self:geteditorstate() )
	if #self.undo_states > 10 then table.remove(self.undo_states, 1) end
	self.redo_states = {}

end


function GUI.TextEditor:geteditorstate()
	
	local state = { retval = {} }
	for k,v in pairs(self.retval) do
		state.retval[k] = v
	end
	state.caret = {x = self.caret.x, y = self.caret.y}	
	
	return state
	
end


-- See if we have a new-enough version of SWS for the clipboard functions
-- (v2.9.7 or greater)
function GUI.TextEditor:SWS_clipboard()
	
	if GUI.SWS_exists then
		return true
	else
	
		reaper.ShowMessageBox(	"Clipboard functions require the SWS extension, v2.9.7 or newer."..
									"\n\nDownload the latest version at http://www.sws-extension.org/index.php",
									"Sorry!", 0)
		return false
	
	end
	
end


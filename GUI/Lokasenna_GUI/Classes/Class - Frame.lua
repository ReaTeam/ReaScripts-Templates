--[[	Lokasenna_GUI - Frame class
	
	---- User parameters ----

	(name, z, x, y, w, h[, shadow, fill, color, round])

Required:
z				Element depth, used for hiding and disabling layers. 1 is the highest.
x, y			Coordinates of top-left corner
w, h			Frame size

Optional:
shadow			Boolean. Draw a shadow beneath the frame?	Defaults to False.
fill			Boolean. Fill in the frame?	Defaults to False.
color			Frame (and fill) color.	Defaults to "elm_frame".
round			Radius of the frame's corners. Defaults to 0.

Additional:
text			Text to be written inside the frame. Will automatically be wrapped
				to fit self.w - 2*self.pad.
txt_indent		Number of spaces to indent the first line of each paragraph
txt_pad			Number of spaces to indent wrapped lines (to match up with bullet
				points, etc)
pad				Padding between the frame's edges and text. Defaults to 0.				
bg				Color to be drawn underneath the text. Defaults to "wnd_bg",
				but will use the frame's fill color instead if Fill = True
font			Text font. Defaults to preset 4.
col_txt			Text color. Defaults to "txt".


Extra methods:


GUI.Val()		Returns the frame's text.
GUI.Val(new)	Sets the frame's text and formats it to fit within the frame, as above.

	
	
]]--

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end



GUI.Frame = GUI.Element:new()
function GUI.Frame:new(name, z, x, y, w, h, shadow, fill, color, round)
	
	local Frame = {}
	Frame.name = name
	Frame.type = "Frame"
	
	Frame.z = z
	GUI.redraw_z[z] = true	
	
	Frame.x, Frame.y, Frame.w, Frame.h = x, y, w, h
	
	Frame.shadow = shadow or false
	Frame.fill = fill or false
	Frame.color = color or "elm_frame"
	Frame.round = 0
	
	Frame.text = ""
	Frame.txt_indent = 0
	Frame.txt_pad = 0
	Frame.bg = "wnd_bg"
	Frame.font = 4
	Frame.col_txt = "txt"
	Frame.pad = 4
	
	
	setmetatable(Frame, self)
	self.__index = self
	return Frame
	
end


function GUI.Frame:init()
	
	if self.text ~= "" then
		self.text = GUI.word_wrap(self.text, self.font, self.w - 2*self.pad, self.txt_indent, self.txt_pad)
	end
	
end


function GUI.Frame:draw()
	
	if self.color == "none" then return 0 end
	
	local x, y, w, h = self.x, self.y, self.w, self.h
	local dist = GUI.shadow_dist
	local fill = self.fill
	local round = self.round
	local shadow = self.shadow
	
	if shadow then
		GUI.color("shadow")
		for i = 1, dist do
			if round > 0 then
				GUI.roundrect(x + i, y + i, w, h, round, 1, fill)
			else
				gfx.rect(x + i, y + i, w, h, fill)
			end
		end
	end
	
	
	GUI.color(self.color)
	if round > 0 then
		GUI.roundrect(x, y, w, h, round, 1, fill)
	else
		gfx.rect(x, y, w, h, fill)
	end
	
	if self.text then
		
		GUI.font(self.font)
		GUI.color(self.col_txt)
		
		gfx.x, gfx.y = self.x + self.pad, self.y + self.pad
		if not fill then GUI.text_bg(self.text, self.bg) end
		gfx.drawstr(self.text)		
		
	end	

end

function GUI.Frame:val(new)

	if new then
		self.text = GUI.word_wrap(new, self.font, self.w - 2*self.pad, self.txt_indent, self.txt_pad)
		GUI.redraw_z[self.z] = true
	else
		return self.text
	end

end


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
	Frame.round = round or 0
	
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
    
    self.buff = self.buff or GUI.GetBuffer()
    
    gfx.dest = self.buff
    gfx.setimgdim(self.buff, -1, -1)
    gfx.setimgdim(self.buff, 2 * self.w + 4, self.h + 2)

    self:drawframe()

    self:drawtext()
    
end


function GUI.Frame:draw()
	
    local x, y, w, h = self.x, self.y, self.w, self.h
    
    if self.shadow then
        
        for i = 1, GUI.shadow_dist do
            
            gfx.blit(self.buff, 1, 0, w + 2, 0, w + 2, h + 2, x + i - 1, y + i - 1)
            
        end
        
    end
    
    gfx.blit(self.buff, 1, 0, 0, 0, w + 2, h + 2, x - 1, y - 1) 

end


function GUI.Frame:val(new)

	if new then
		self.text = new
        self:init()
		GUI.redraw_z[self.z] = true
	else
		return string.gsub(self.text, "\n", "")
	end

end




------------------------------------
-------- Drawing methods -----------
------------------------------------


function GUI.Frame:drawframe()
    
    local w, h = self.w, self.h
	local fill = self.fill
	local round = self.round
    
    -- Frame background
    GUI.color(self.bg)
    if round > 0 then
        GUI.roundrect(1, 1, w, h, round, 1, true)
    else
        gfx.rect(1, 1, w, h, true)
    end
    
    
    -- Shadow
    local r, g, b, a = table.unpack(GUI.colors["shadow"])
	gfx.set(r, g, b, 1)
	GUI.roundrect(self.w + 2, 1, self.w, self.h, 4, 1, 1)
	gfx.muladdrect(self.w + 2, 1, self.w + 2, self.h + 2, 1, 1, 1, a, 0, 0, 0, 0 )

    
    -- Frame
	GUI.color(self.color)
	if round > 0 then
		GUI.roundrect(1, 1, w, h, round, 1, fill)
	else
		gfx.rect(1, 1, w, h, fill)
	end

end


function GUI.Frame:drawtext()
    
	if self.text and self.text:len() > 0 then

		self.text = GUI.word_wrap(  self.text, self.font, self.w - 2*self.pad, 
                                    self.txt_indent, self.txt_pad)

		GUI.font(self.font)
		GUI.color(self.col_txt)
        
		gfx.x, gfx.y = self.pad + 1, self.pad + 1
		if not fill then GUI.text_bg(self.text, self.bg) end
		gfx.drawstr(self.text)
		
	end
    
end
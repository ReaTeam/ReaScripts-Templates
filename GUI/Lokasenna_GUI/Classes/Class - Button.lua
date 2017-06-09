--[[	Lokasenna_GUI - Button class 
	
	(Adapted from eugen2777's simple GUI template.)
	
	---- User parameters ----

	(name, z, x, y, w, h, caption, func[, ...])

Required:
z				Element depth, used for hiding and disabling layers. 1 is the highest.
x, y			Coordinates of top-left corner
w, h			Button size
caption			Label
func			Function to perform when clicked

Optional:
...				Any parameters to pass to that function, separated by commas as they
				would be if calling the function directly.


Additional:
r_func			Function to perform when right-clicked
r_params		If provided, any parameters to pass to that function
font			Button label's font
col_txt			Button label's color

col_fill		Button color. 
				*** If you change this, call :init() afterward ***


Extra methods:
exec			Force a button-click, i.e. for allowing buttons to have a hotkey:
					[Y]es	[N]o	[C]ancel
					
				Params:
				r			Boolean, optional. r = true will run the button's
							right-click action instead

]]--

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end


-- Button - New
GUI.Button = GUI.Element:new()
function GUI.Button:new(name, z, x, y, w, h, caption, func, ...)

	local Button = {}
	
	Button.name = name
	Button.type = "Button"
	
	Button.z = z
	GUI.redraw_z[z] = true	
	
	Button.x, Button.y, Button.w, Button.h = x, y, w, h

	Button.caption = caption
	
	Button.font = 3
	Button.col_txt = "txt"
	Button.col_fill = "elm_frame"
	
	Button.func = func or function () end
	Button.params = {...}
	
	Button.state = 0

	setmetatable(Button, self)
	self.__index = self
	return Button

end


function GUI.Button:init()
	
	self.buff = self.buff or GUI.GetBuffer()
	
	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2*self.w + 4, self.h + 2)
	
	GUI.color(self.col_fill)
	GUI.roundrect(1, 1, self.w, self.h, 4, 1, 1)
	GUI.color("elm_outline")
	GUI.roundrect(1, 1, self.w, self.h, 4, 1, 0)
	
	
	local r, g, b, a = table.unpack(GUI.colors["shadow"])
	gfx.set(r, g, b, 1)
	GUI.roundrect(self.w + 2, 1, self.w, self.h, 4, 1, 1)
	gfx.muladdrect(self.w + 2, 1, self.w + 2, self.h + 2, 1, 1, 1, a, 0, 0, 0, 0 )
	
	
end


function GUI.Button:ondelete()
	
	GUI.FreeBuffer(self.buff)
	
end



-- Button - Draw.
function GUI.Button:draw()
	
	local x, y, w, h = self.x, self.y, self.w, self.h
	local state = self.state
		
	
	-- Draw the shadow if not pressed
	if state == 0 then
		
		for i = 1, GUI.shadow_dist do
			
			gfx.blit(self.buff, 1, 0, w + 2, 0, w + 2, h + 2, x + i - 1, y + i - 1)
			
		end

	end
	
	gfx.blit(self.buff, 1, 0, 0, 0, w + 2, h + 2, x + 2 * state - 1, y + 2 * state - 1) 	
	
	-- Draw the caption
	GUI.color(self.col_txt)
	GUI.font(self.font)	
	
	local str_w, str_h = gfx.measurestr(self.caption)
	gfx.x = x + 2 * state + ((w - str_w) / 2)-- - 2
	gfx.y = y + 2 * state + ((h - str_h) / 2)-- - 2
	gfx.drawstr(self.caption)
	
end


-- Button - Mouse down.
function GUI.Button:onmousedown()
	
	self.state = 1
	GUI.redraw_z[self.z] = true

end


-- Button - Mouse up.
function GUI.Button:onmouseup() 
	
	self.state = 0
	
	-- If the mouse was released on the button, run func
	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) then
		
		self.func(table.unpack(self.params))
		
	end
	GUI.redraw_z[self.z] = true

end

function GUI.Button:ondoubleclick()
	
	self.state = 0
	
	end


-- Button - Right mouse up
function GUI.Button:onmouser_up()

	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) and self.r_func then
	
		self.r_func(table.unpack(self.r_params))

	end
end


-- Button - Execute (extra method)
-- Used for allowing hotkeys to press a button
function GUI.Button:exec(r)
	
	if r then
		self.r_func(table.unpack(self.r_params))
	else
		self.func(table.unpack(self.params))
	end
	
end


--[[	Lokasenna_GUI - Knob class.

	---- User parameters ----
	
	(name, z, x, y, w, caption, min, max, steps, default[, vals])
	
Required:	
z				Element depth, used for hiding and disabling layers. 1 is the highest.	
x, y, w			Coordinates of top-left corner, width. Height is fixed.
caption			Label / question
min, max		Minimum and maximum values
steps			How many steps between min and max (inclusive, i.e. 0-11 = 12 steps)
default			What step the knob should start on (as above, a default of 12 would start at value 11)


Optional:
vals			Boolean. Display value labels?
				For knobs with a lot of steps, i.e. Pan from -100 to +100, set this
				to false and use a label to read the value, update the Knob's caption


Additional:
bg				Color to be drawn underneath the label. Defaults to "wnd_bg"
output			Allows the value labels to be modified; accepts several different var types:
				
				string		Replaces all of the value labels
				number
				table		Replaces each value label with output[step], with the steps
							being numbered as above
				functions	Replaces each value with the returned value from
							output(step), numbered as above
							
Extra methods:



GUI.Val()		Returns the current display value of the knob. i.e. 
				
					For a Pan knob, -100 to +100, with 201 steps,
					GUI.Val("my_knob") will return an integer from -100 to +100
					
GUI.Val(new)	Sets the display value of the knob, as above.				
	
]]--

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

-- Knob - New.
GUI.Knob = GUI.Element:new()
function GUI.Knob:new(name, z, x, y, w, caption, min, max, steps, default, vals)
	
	local Knob = {}
	
	Knob.name = name
	Knob.type = "Knob"
	
	Knob.z = z
	GUI.redraw_z[z] = true	
	
	Knob.x, Knob.y, Knob.w, Knob.h = x, y, w, w

	Knob.caption = caption
	Knob.bg = "wnd_bg"
	
	Knob.font_a = 3
	Knob.font_b = 4
	
	Knob.col_txt = "txt"
	Knob.col_head = "elm_fill"
	Knob.col_body = "elm_frame"
	
	Knob.min, Knob.max = min, max
	
	Knob.steps, Knob.vals = steps - 1, vals
	
	-- Determine the step angle
	Knob.stepangle = (3 / 2) / Knob.steps
	
	Knob.default, Knob.curstep = default - 1, default - 1
	
	Knob.retval = GUI.round(((max - min) / Knob.steps) * Knob.curstep + min)

	Knob.curval = Knob.curstep / Knob.steps
	
	setmetatable(Knob, self)
	self.__index = self
	return Knob

end


function GUI.Knob:init()
	
	self.buff = GUI.GetBuffer()
	
	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)




		---- The knob ----
	
	-- Figure out the points of the triangle
	--local curangle = (-5 / 4) + (curstep * stepangle) 
	local r = self.w / 2
	local rp = r * 1.5
	local curangle = 0
	local o = rp + 1
	
	local w = 2 * rp + 2

	gfx.setimgdim(self.buff, 2*w, w)


	local Ax, Ay = GUI.polar2cart(curangle, rp, o, o)
	
	--[[	old, knob's head was too narrow
	local Bx, By = GUI.polar2cart(curangle + 1/2, r - 1, o.x, o.y)
	local Cx, Cy = GUI.polar2cart(curangle - 1/2, r - 1, o.x, o.y)
	]]--
	
	local side_angle = (math.acos(0.666667) / GUI.pi) * 0.9
	local Bx, By = GUI.polar2cart(curangle + side_angle, r - 1, o, o)
	local Cx, Cy = GUI.polar2cart(curangle - side_angle, r - 1, o, o)
	
	
	-- Head
	GUI.color(self.col_head)
	GUI.triangle(1, Ax, Ay, Bx, By, Cx, Cy)
	GUI.color("elm_outline")
	GUI.triangle(0, Ax, Ay, Bx, By, Cx, Cy)	
	
	-- Body
	GUI.color(self.col_body)
	gfx.circle(o, o, r, 1)
	GUI.color("elm_outline")
	gfx.circle(o, o, r, 0)		

	--gfx.blit(source, scale, rotation[, srcx, srcy, srcw, srch, destx, desty, destw, desth, rotxoffs, rotyoffs] )
	gfx.blit(self.buff, 1, 0, 0, 0, w, w, w + 1, 0)
	gfx.muladdrect(w + 1, 0, w, w, 0, 0, 0, GUI.colors["shadow"][4])

end


function GUI.Knob:ondelete()
	
	GUI.FreeBuffer(self.buff)	
	
end


-- Knob - Draw
function GUI.Knob:draw()
	
	
	local x, y, w = self.x, self.y, self.w

	local caption = self.caption
	
	local min, max = self.min, self.max

	local default = self.default
	
	local vals = self.vals
	local stepangle = self.stepangle
	
	local curstep = self.curstep
	
	local steps = self.steps
	
	local r = w / 2
	local o = {x = x + r, y = y + r}
	
	
	-- Figure out where the knob is pointing
	local curangle = (-5 / 4) + (curstep * stepangle)
	

	-- Ticks and labels	
	if vals then
		
		--GUI.font(4)
		
		for i = 0, steps do
			
			local angle = (-5 / 4 ) + (i * stepangle)
			

			--[[	Disabled; the lines don't show up well after blitting
				
			-- Tick marks
			local x1, y1 = GUI.polar2cart(angle, r * 1.2, o.x, o.y)
			local x2, y2 = GUI.polar2cart(angle, r * 1.6, o.x, o.y)
			
			GUI.color(self.bg)
			gfx.rect(x1 - 2, y1 - 2, (x2 - x1 + 4), (y2 - y1 + 4), true)
			GUI.color("elm_frame")				
			gfx.line(x1, y1, x2, y2)
			]]--
			
			-- Highlight the current value
			if i == curstep then
				GUI.color(self.col_head)
				GUI.font({GUI.fonts[self.font_b][1], GUI.fonts[self.font_b][2] * 1.2, "b"})
			else
				GUI.color(self.col_txt)
				GUI.font(self.font_b)
			end
			
			local output = i

			if self.output then
				local t = type(self.output)

				if t == "string" or t == "number" then
					output = self.output
				elseif t == "table" then
					output = self.output[i]
				elseif t == "function" then
					output = self.output(i)
				end
			end
			
			-- Avoid any crashes from weird user data
			output = tostring(output)

			if output ~= "" then
				
				local str_w, str_h = gfx.measurestr(output)
				local cx, cy = GUI.polar2cart(angle, r * 2, o.x, o.y)		
				gfx.x, gfx.y = cx - str_w / 2, cy - str_h / 2
				GUI.text_bg(output, self.bg)
				gfx.drawstr(output)
			end			
				
		end
	end
	
	
	-- Caption
	
	GUI.font(self.font_a)
	cx, cy = GUI.polar2cart(1/2, r * 2, o.x, o.y)
	local str_w, str_h = gfx.measurestr(caption)
	gfx.x, gfx.y = cx - str_w / 2, cy - str_h / 2
	GUI.text_bg(caption, self.bg)
	GUI.shadow(caption, self.col_txt, "shadow")

	local bw = 3 * r + 2
	local bx = 1.5 * r

	-- Shadow
	for i = 1, GUI.shadow_dist do
		
		gfx.blit(self.buff, 1, curangle * GUI.pi, bw + 1, 0, bw, bw, o.x - bx + i - 1, o.y - bx + i - 1)	
		
	end
	
	-- Body
	
	gfx.blit(self.buff, 1, curangle * GUI.pi, 0, 0, bw, bw, o.x - bx - 1, o.y - bx - 1)


	--self.retval = GUI.round(((max - min) / steps) * curstep + min)
	
end


-- Knob - Get/set value
function GUI.Knob:val(newval)
	
	if newval then
		self.retval = newval
		self.curstep = newval - self.min
		self.curval = self.curstep / self.steps

		GUI.redraw_z[self.z] = true

	else
		return self.retval
	end	

end


-- Knob - Dragging.
function GUI.Knob:ondrag()
	
	local y = GUI.mouse.y
	local ly = GUI.mouse.ly

	-- Ctrl?
	local ctrl = GUI.mouse.cap&4==4
	
	-- Multiplier for how fast the knob turns. Higher = slower
	--					Ctrl	Normal
	local adj = ctrl and 1200 or 150
	
	self.curval = self.curval + ((ly - y) / adj)
	if self.curval > 1 then self.curval = 1 end
	if self.curval < 0 then self.curval = 0 end
	
	self.curstep = GUI.round(self.curval * self.steps)
	
	self.retval = GUI.round(((self.max - self.min) / self.steps) * self.curstep + self.min)

	GUI.redraw_z[self.z] = true

end


-- Knob - Mousewheel
function GUI.Knob:onwheel()

	local ctrl = GUI.mouse.cap&4==4
	
	-- How many steps per wheel-step
	local fine = 1
	local coarse = math.max( GUI.round(self.steps / 30), 1)

	local adj = ctrl and fine or coarse
	
	self.curval = self.curval + GUI.mouse.inc * adj / self.steps
	
	if self.curval < 0 then self.curval = 0 end
	if self.curval > 1 then self.curval = 1 end

	self.curstep = GUI.round(self.curval * self.steps)
	
	self:val()

	GUI.redraw_z[self.z] = true

end


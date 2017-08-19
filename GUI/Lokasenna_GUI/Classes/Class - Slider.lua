--[[	Lokasenna_GUI - Slider class

	---- User parameters ----

	(name, z, x, y, w, caption, min, max, steps, handles[, dir])

Required:
z				Element depth, used for hiding and disabling layers. 1 is the highest.
x, y			Coordinates of top-left corner
w				Width of the slider track. Height is fixed.
caption			Label shown above the slider track.
min, max		Minimum and maximum values
steps			The number of steps the slider can be set to. The value is non-inclusive,
				i.e. a slider from 0 - 30 would have 30 steps.
handles			Table of default values (in steps, as per above) of each slider handle:

					{5, 10, 15, 20, 25} would create a slider with five handles.
					
				If only one handle is needed, it can be given as a number rather than a table.

				Examples:
				
					A pan slider from -100 to 100, defaulting to 0:
						min		= -100
						max		= 100
						steps	= 200
						handles	= 100

					Five sliders from 0 to 30, defaulting to 5, 10, 15, 20, 25:
						min		= 0
						max		= 30
						steps	= 30
						handles = {5, 10, 15, 20, 25}

Optional:
dir				**not yet implemented**
				"h"	Horizontal slider (default)
				"v"	Vertical slider


Additional:
bg				Color to be drawn underneath the label. Defaults to "wnd_bg"
font_a			Label font
font_b			Value font
col_txt			Text color
col_fill		Fill bar color
show_handles	Boolean. If false, will hide the slider handles.
				i.e. displaying a VU meter
show_values		Boolean. If false, will hide the handles' value labels.
cap_x, cap_y	Offset values for the slider's caption

output			Allows the value labels to be modified; accepts several different var types:
				
				string		Replaces all of the value labels
				number
				table		Replaces each value label with self.output[retval]
				functions	Replaces each value with the returned value from
							self.output(retval)
							


Extra methods:


GUI.Val()		Returns a table of values for each handle, sorted from smallest to largest
GUI.Val(new)	Accepts a table of values for each handle, as above


	
]]--


if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

GUI.Slider = GUI.Element:new()

function GUI.Slider:new(name, z, x, y, w, caption, min, max, steps, handles, dir)
	
	local Slider = {}
	
	Slider.name = name
	Slider.type = "Slider"
	
	Slider.z = z
	GUI.redraw_z[z] = true

	Slider.x, Slider.y = x, y
	Slider.w, Slider.h = table.unpack(dir ~= "v" and {w, 8} or {8, w})

	Slider.caption = caption
	Slider.bg = "wnd_bg"
	
	Slider.font_a = 3
	Slider.font_b = 4
	
	Slider.col_txt = "txt"
	Slider.col_hnd = "elm_frame"
	Slider.col_fill = "elm_fill"
	
	Slider.dir = dir or "h"
	
	if Slider.dir == "v" then
		min, max = max, min
		
	end
	
	Slider.show_handles = true
	Slider.show_values = true
	
	Slider.cap_x = 0
	Slider.cap_y = 0
	
	Slider.min, Slider.max = min, max
	Slider.steps = steps
	
	-- If the user only asked for one handle
	if type(handles) == "number" then handles = {handles} end

	Slider.handles = {}
	for i = 1, #handles do
		
		Slider.handles[i] = {}
		Slider.handles[i].default = (dir ~= "v" and handles[i] or (steps - handles[i]))
		Slider.handles[i].curstep = handles[i]
		Slider.handles[i].curval = handles[i] / steps
		Slider.handles[i].retval = GUI.round(((max - min) / steps) * handles[i] + min)
		--Slider.handles[i].retval = ((max - min) / (steps - 1)) * handles[i] + min
		
	end
	
	setmetatable(Slider, self)
	self.__index = self
	return Slider	
	
end


function GUI.Slider:init()
	
	self.buff = self.buff or GUI.GetBuffer()

	local hw, hh = table.unpack(self.dir == "h" and {8, 16} or {16, 8})

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2 * hw + 4, hh + 2)
	
	GUI.color(self.col_hnd)
	GUI.roundrect(1, 1, hw, hh, 2, 1, 1)
	GUI.color("elm_outline")
	GUI.roundrect(1, 1, hw, hh, 2, 1, 0)
	
	local r, g, b, a = table.unpack(GUI.colors["shadow"])
	gfx.set(r, g, b, 1)
	GUI.roundrect(hw + 2, 1, hw, hh, 2, 1, 1)
	gfx.muladdrect(hw + 2, 1, hw + 2, hh + 2, 1, 1, 1, a, 0, 0, 0, 0 )

end


function GUI.Slider:ondelete()
	
	GUI.FreeBuffer(self.buff)	
	
end


-- Slider - Draw
function GUI.Slider:draw()

	local x, y, w, h = self.x, self.y, self.w, self.h

	local steps = self.steps
	
	local min, max = self.min, self.max
	
		---- Common code, pre-Direction ----


	-- Draw track
	GUI.color("elm_bg")
	GUI.roundrect(x, y, w, h, 4, 1, 1)
	GUI.color("elm_outline")
	GUI.roundrect(x, y, w, h, 4, 1, 0)

	



	local fill = (#self.handles > 1) or self.handles[1].curstep ~= self.handles[1].default
	
	if fill then
		
		-- If the user has given us two colors to make a gradient with
		if self.col_fill_a and #self.handles == 1 then
			
			-- Make a gradient, 
			local col_a = GUI.colors[self.col_fill_a]
			local col_b = GUI.colors[self.col_fill_b]
			local grad_step = self.handles[1].curstep / steps

			local r, g, b, a = GUI.gradient(col_a, col_b, grad_step)

			gfx.set(r, g, b, a)
								
		else
			GUI.color(self.col_fill)
		end
		
	end


	-- Handles

	if self.dir == "h" then
		
		-- Limit everything to be drawn within the square part of the track
		x, w = x + 4, w - 8
		
		-- Size of the handle
		local hw, hh = 8, h * 2
		local inc = w / steps
		local fill_min, fill_max
		local hy = y + (h - hh) / 2

		-- Get the handles' coordinates and the fill bar
		local x_min, x_max
		
		for i = 1, #self.handles do
			
			local cx = x + inc * self.handles[i].curstep
			self.handles[i].x, self.handles[i].y = cx - (hw / 2), hy
			
			if not x_min or cx < x_min then	x_min = cx end
			if not x_max or cx > x_max then x_max = cx end
			
		end

		-- Draw the fill bar

		if #self.handles == 1 then
			x_min = x + inc * self.handles[1].default
			
			gfx.circle(x_min, y + (h / 2), h / 2 - 1, 1, 1)	
			if x_min > x_max then x_min, x_max = x_max, x_min end
		end
		
		gfx.rect(x_min, y + 1, x_max - x_min, h - 1, 1)


		-- Drawing them in reverse order so overlaps match the shadow direction
		for i = #self.handles, 1, -1 do
		
			local hx, hy = GUI.round(self.handles[i].x) - 1, GUI.round(self.handles[i].y) - 1
			
			if self.show_values then
				GUI.color(self.col_txt)
				GUI.font(self.font_b)

				local output = self.handles[i].retval
					
				if self.output then
					local t = type(self.output)

					if t == "string" or t == "number" then
						output = self.output
					elseif t == "table" then
						output = self.output[output]
					elseif t == "function" then
						output = self.output(output)
					end
				end				
								
				local str_w, str_h = gfx.measurestr(output)
				gfx.x = hx + (hw - str_w) / 2 + 1
				gfx.y = y + h + h
				GUI.text_bg(output, self.bg)
				gfx.drawstr(output)				
			end

			if self.show_handles then
				for j = 1, GUI.shadow_dist do

					gfx.blit(self.buff, 1, 0, hw + 2, 0, hw + 2, hh + 2, hx + j, hy + j)
					
				end

			
				--gfx.blit(source, scale, rotation[, srcx, srcy, srcw, srch, destx, desty, destw, desth, rotxoffs, rotyoffs] )
			
				gfx.blit(self.buff, 1, 0, 0, 0, hw + 2, hh + 2, hx, hy) 	
			end
			
		end


	elseif self.dir == "v" then
	
		-- Limit everything to be drawn within the square part of the track
		y, h = y + 4, h - 8	
	
		-- Size of the handle
		local hw, hh = w * 2, 8
		local inc = h / steps
		local fill_min, fill_max
		local hx = x + (w - hw) / 2

		-- Get the handles' coordinates and the fill bar
		local y_min, y_max
		
		for i = 1, #self.handles do
			
			local cy = y + inc * self.handles[i].curstep
			self.handles[i].x, self.handles[i].y = hx, cy - (hh / 2)
			
			if not y_min or cy < y_min then	y_min = cy end
			if not y_max or cy > y_max then y_max = cy end
	
		end

		-- Draw the fill bar

		if #self.handles == 1 then
			y_min = y + inc * self.handles[1].default
			
			gfx.circle(x + (w / 2), y_min, w / 2 - 1, 1, 1)	
			if y_min > y_max then y_min, y_max = y_max, y_min end
		end
		
		gfx.rect(x + 1, y_min, w - 1, y_max - y_min, 1)


		-- Drawing them in reverse order so overlaps match the shadow direction
		for i = #self.handles, 1, -1 do
		
			local hx, hy = GUI.round(self.handles[i].x) - 1, GUI.round(self.handles[i].y) - 1

			if self.show_values then
				GUI.color(self.col_txt)
				GUI.font(self.font_b)

				local output = self.handles[i].retval
					
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
								
				local str_w, str_h = gfx.measurestr(output)
				gfx.x = x + w + w
				gfx.y = hy + (hh - str_h) / 2 + 1
				GUI.text_bg(output, self.bg)
				gfx.drawstr(output)
				
			end
			
			if self.show_handles then
				for j = 1, GUI.shadow_dist do

					gfx.blit(self.buff, 1, 0, hw + 2, 0, hw + 2, hh + 2, hx + j, hy + j)
					
				end
				
				--gfx.blit(source, scale, rotation[, srcx, srcy, srcw, srch, destx, desty, destw, desth, rotxoffs, rotyoffs] )
				
				gfx.blit(self.buff, 1, 0, 0, 0, hw + 2, hh + 2, hx, hy) 	
			end
	
		end
	
	
	end


	-- Draw caption	
	GUI.font(self.font_a)
	
	local str_w, str_h = gfx.measurestr(self.caption)
	--[[
	gfx.x = x + (w - str_w) / 2
	gfx.y = y - h - str_h
	]]--
	gfx.x = x + (w - str_w) / 2 + self.cap_x
	gfx.y = y - (self.dir ~= "v" and h or w) - str_h + self.cap_y
	GUI.text_bg(self.caption, self.bg)
	GUI.shadow(self.caption, self.col_txt, "shadow")
	
end



-- Slider - Get/set value
function GUI.Slider:val(newvals)
	
	if newvals then
		
		if type(newvals) == "number" then newvals = {newvals} end
		
		local steps, min, max = self.steps, self.min, self.max
		local inc = (max - min) / steps
		
		for i = 1, #self.handles do
			
			self.handles[i].curstep = newvals[i]
			self.handles[i].curval = self.handles[i].curstep / steps
			self.handles[i].retval = GUI.round( (inc * self.handles[i].curstep) + min)
			
		end
		
		GUI.redraw_z[self.z] = true
	
	else
		
		local ret = {}
		for i = 1, #self.handles do
			
			--dir ~= "v" and handles[i] or (steps - handles[i])
			
			table.insert(ret, (self.dir ~= "v" 	and (self.handles[i].curstep + self.min)
												or	(self.steps - self.handles[i].curstep)))
			
		end
		
		if #ret == 1 then 
			return ret[1]
		else		
			table.sort(ret)
			return ret
		end
		
	end

end


-- Slider - Mouse down
function GUI.Slider:onmousedown()
	
	-- Snap the nearest slider to the nearest value
	
	local mouse_val = self.dir == "h" 
					and (GUI.mouse.x - self.x) / self.w 
					or  (GUI.mouse.y - self.y) / self.h	
	
	local small_diff, small_idx
	
	for i = 1, #self.handles do

		local diff = math.abs( self.handles[i].curval - mouse_val )
	
		if not small_diff or (math.abs( self.handles[i].curval - mouse_val ) < small_diff) then
			small_diff = diff
			small_idx = i

		end
		
	end
	
	cur = small_idx
	self.cur_handle = cur

	mouse_val = GUI.clamp(mouse_val, 0, 1)
	
	self.handles[cur].curval = mouse_val
	self.handles[cur].curstep = GUI.round(mouse_val * self.steps)
	self.handles[cur].retval = GUI.round( ( (self.max - self.min) / self.steps ) * self.handles[cur].curstep + self.min )

	GUI.redraw_z[self.z] = true	
	
end


-- Slider - Dragging
function GUI.Slider:ondrag()

	local mouse_val, n, ln = table.unpack(self.dir == "h" 
					and {(GUI.mouse.x - self.x) / self.w, GUI.mouse.x, GUI.mouse.lx}
					or  {(GUI.mouse.y - self.y) / self.h, GUI.mouse.y, GUI.mouse.ly}
	)

	local cur = self.cur_handle or 1
	
	-- Ctrl?
	local ctrl = GUI.mouse.cap&4==4
	
	-- A multiplier for how fast the slider should move. Higher values = slower
	--						Ctrl							Normal
	local adj = ctrl and math.max(1200, (8*self.steps)) or 150
	local adj_scale = (self.dir == "h" and self.w or self.h) / 150
	adj = adj * adj_scale

	self.handles[cur].curval = GUI.clamp( self.handles[cur].curval + ((n - ln) / adj) , 0, 1 )
	self.handles[cur].curstep = GUI.round( self.handles[cur].curval * self.steps )
	self.handles[cur].retval = GUI.round( ( (self.max - self.min) / self.steps ) * self.handles[cur].curstep + self.min )

	--self:sort()
	GUI.redraw_z[self.z] = true

end


-- Slider - Mousewheel
function GUI.Slider:onwheel()
	
	local mouse_val = self.dir == "h" 
					and (GUI.mouse.x - self.x) / self.w 
					or  (GUI.mouse.y - self.y) / self.h	
	
	local inc = GUI.round( self.dir == "h" and GUI.mouse.inc
											or -GUI.mouse.inc )
	
	local small_diff, small_idx	
	
	for i = 1, #self.handles do
		
		local diff = math.abs( self.handles[i].curval - mouse_val )
		if not small_diff or diff < small_diff then
			small_diff = diff
			small_idx = i
		end
		
	end	
	
	local cur = small_idx
	
	
	local ctrl = GUI.mouse.cap&4==4

	-- How many steps per wheel-step
	local fine = 1
	local coarse = math.max( GUI.round(self.steps / 30), 1)

	local adj = ctrl and fine or coarse

	self.handles[cur].curval = GUI.clamp( self.handles[cur].curval + (inc * adj / self.steps) , 0, 1)
	
	self.handles[cur].curstep = GUI.round( self.handles[cur].curval * self.steps )
	self.handles[cur].retval = GUI.round(((self.max - self.min) / self.steps) * self.handles[cur].curstep + self.min)

	--self:sort()
	GUI.redraw_z[self.z] = true

end


function GUI.Slider:ondoubleclick()
	
	local ctrl = GUI.mouse.cap&4==4
	local min, max, steps = self.min, self.max, self.steps
	local inc = (max - min) / steps
	
	if ctrl then
		
		-- Only reset the closest slider
		
		local mouse_val = (GUI.mouse.x - self.x) / self.w
		
		local small_diff, small_idx
	
		for i = 1, #self.handles do
			
			local diff = math.abs( self.handles[i].curval - mouse_val )
			if not small_diff or diff < small_diff then
				small_diff = diff
				small_idx = i
			end
			
		end	

			
		local cur = small_idx
		
		self.handles[cur].curstep = self.handles[cur].default
		self.handles[cur].curval = self.handles[cur].curstep / self.steps
		self.handles[cur].retval = GUI.round(inc * self.handles[cur].curstep + self.min)
		
	else
	
		for i = 1, #self.handles do
			
			self.handles[i].curstep = self.handles[i].default
			self.handles[i].curval = self.handles[i].curstep / self.steps
			self.handles[i].retval = GUI.round(inc * self.handles[i].curstep + self.min)	
			
		end
		
	end

	--self:sort()
	GUI.redraw_z[self.z] = true
	
end

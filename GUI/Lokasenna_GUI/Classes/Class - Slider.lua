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
dir				"h"	Horizontal slider (default)
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
	
	self.buffs = self.buffs or GUI.GetBuffer(2)

    local w, h = self.w, self.h

    -- Track
    gfx.dest = self.buffs[1]
    gfx.setimgdim(self.buffs[1], -1, -1)
    gfx.setimgdim(self.buffs[1], w + 4, h + 4)

	GUI.color("elm_bg")
	GUI.roundrect(2, 2, w, h, 4, 1, 1)
	GUI.color("elm_outline")
	GUI.roundrect(2, 2, w, h, 4, 1, 0)
    

    -- Handle
	local hw, hh = table.unpack(self.dir == "h" and {8, 16} or {16, 8})

	gfx.dest = self.buffs[2]
	gfx.setimgdim(self.buffs[2], -1, -1)
	gfx.setimgdim(self.buffs[2], 2 * hw + 4, hh + 2)
	
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
	
	GUI.FreeBuffer(self.buffs)	
	
end


function GUI.Slider:draw()

    local x, y, w, h = self.x, self.y, self.w, self.h

	-- Draw track
    gfx.blit(self.buffs[1], 1, 0, 1, 1, w + 2, h + 2, x - 1, y - 1)

    -- To avoid a LOT of copy/pasting for vertical sliders, we can
    -- just swap x-y and w-h to effectively "rotate" all of the math
    -- 90 degrees. 'horz' is here to help out in a few situations where
    -- the values need to be swapped back for drawing stuff.
    
    local horz = self.dir ~= "v"
    if not horz then x, y, w, h = y, x, h, w end
		
    -- Limit everything to be drawn within the square part of the track
    x, w = x + 4, w - 8
    
    -- Size of the handle
    local handle_w, handle_h = 8, h * 2
    local inc = w / self.steps
    local handle_y = y + (h - handle_h) / 2

    -- Get the handles' coordinates and the ends of the fill bar
    local min, max = self:updatehandlecoords(x, handle_w, handle_y, inc)
    
    self:drawfill(x, y, h, min, max, inc, horz)

    self:drawsliders(x, y, h, handle_w, handle_h, horz)
    if self.caption and self.caption ~= "" then self:drawcaption() end
	
end


function GUI.Slider:val(newvals)
	
	if newvals then
		
		if type(newvals) == "number" then newvals = {newvals} end
		
		local steps, min, max = self.steps, self.min, self.max
		local inc = (max - min) / steps
		
		for i = 1, #self.handles do
			
            self:setcurstep(i, newvals[i])
			
		end
		
		GUI.redraw_z[self.z] = true
	
	else
		
		local ret = {}
		for i = 1, #self.handles do
			
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




------------------------------------
-------- Input methods -------------
------------------------------------


function GUI.Slider:onmousedown()
	
	-- Snap the nearest slider to the nearest value
	
	local mouse_val = self.dir == "h" 
					and (GUI.mouse.x - self.x) / self.w 
					or  (GUI.mouse.y - self.y) / self.h	
	
    self.cur_handle = self:getnearesthandle(mouse_val)
	
	self:setcurval(self.cur_handle, GUI.clamp(mouse_val, 0, 1) )

	GUI.redraw_z[self.z] = true	
	
end


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

    self:setcurval(cur, GUI.clamp( self.handles[cur].curval + ((n - ln) / adj) , 0, 1 ) )

	GUI.redraw_z[self.z] = true

end


function GUI.Slider:onwheel()
	
	local mouse_val = self.dir == "h" 
					and (GUI.mouse.x - self.x) / self.w 
					or  (GUI.mouse.y - self.y) / self.h	
	
	local inc = GUI.round( self.dir == "h" and GUI.mouse.inc
											or -GUI.mouse.inc )
	
    local cur = self:getnearesthandle(mouse_val)	
	
	local ctrl = GUI.mouse.cap&4==4

	-- How many steps per wheel-step
	local fine = 1
	local coarse = math.max( GUI.round(self.steps / 30), 1)

	local adj = ctrl and fine or coarse

    self:setcurval(cur, GUI.clamp( self.handles[cur].curval + (inc * adj / self.steps) , 0, 1) )
	
	GUI.redraw_z[self.z] = true

end


function GUI.Slider:ondoubleclick()
	
    -- Ctrl+click - Only reset the closest slider to the mouse
	if GUI.mouse.cap & 4 == 4 then
		
		local mouse_val = (GUI.mouse.x - self.x) / self.w		
		local small_diff, small_idx
		for i = 1, #self.handles do
			
			local diff = math.abs( self.handles[i].curval - mouse_val )
			if not small_diff or diff < small_diff then
				small_diff = diff
				small_idx = i
			end
			
		end	

        self:setcurstep(small_idx, self.handles[small_idx].default)
    
    -- Reset all sliders
	else
	
		for i = 1, #self.handles do
			
            self:setcurstep(i, self.handles[i].default)
            
		end
		
	end

	GUI.redraw_z[self.z] = true
	
end




------------------------------------
-------- Drawing helpers -----------
------------------------------------


function GUI.Slider:updatehandlecoords(x, handle_w, handle_y, inc)
    
    local min, max
    
    for i = 1, #self.handles do
        
        local center = x + inc * self.handles[i].curstep
        self.handles[i].x, self.handles[i].y = center - (handle_w / 2), handle_y
        
        if not min or center < min then min = center end
        if not max or center > max then max = center end
        
    end
    
    return min, max
    
end    


function GUI.Slider:drawfill(x, y, h, min, max, inc, horz)
    
    -- Get the color
	if (#self.handles > 1) 
    or self.handles[1].curstep ~= self.handles[1].default then
    
        self:setfill()
    
    end    
    
    -- Cap for the fill bar
    if #self.handles == 1 then
        min = x + inc * self.handles[1].default
        
        _ = horz and gfx.circle(min, y + (h / 2), h / 2 - 1, 1, 1)
                 or  gfx.circle(y + (h / 2), min, h / 2 - 1, 1, 1)

    end
    
    if min > max then min, max = max, min end

    _ = horz and gfx.rect(min, y + 1, max - min, h - 1, 1)
             or  gfx.rect(y + 1, min, h - 1, max - min, 1)
             
end  


function GUI.Slider:setfill()
    
    -- If the user has given us two colors to make a gradient with
    if self.col_fill_a and #self.handles == 1 then
        
        -- Make a gradient, 
        local col_a = GUI.colors[self.col_fill_a]
        local col_b = GUI.colors[self.col_fill_b]
        local grad_step = self.handles[1].curstep / self.steps

        local r, g, b, a = GUI.gradient(col_a, col_b, grad_step)

        gfx.set(r, g, b, a)
                            
    else
        GUI.color(self.col_fill)
    end
    
end


function GUI.Slider:drawsliders(x, y, h, handle_w, handle_h, horz)

    GUI.color(self.col_txt)
    GUI.font(self.font_b)

    -- Drawing them in reverse order so overlaps match the shadow direction
    for i = #self.handles, 1, -1 do
    
        local handle_x, handle_y = GUI.round(self.handles[i].x) - 1, GUI.round(self.handles[i].y) - 1
        
        if self.show_values then
            
            local x, y =    handle_x,
                            y + h + h
            
            if horz then
                self:drawslidervalue(x, y, i)
            else
                self:drawslidervalue(y, x - 2, i)
            end
            
        end

        if self.show_handles then
            
            if horz then
                self:drawsliderhandle(handle_x, handle_y, handle_w, handle_h)
            else
                self:drawsliderhandle(handle_y, handle_x, handle_h, handle_w)
            end

        end
        
    end

end


function GUI.Slider:drawslidervalue(x, y, sldr)
    
    local output = self.handles[sldr].retval
        
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

    gfx.x, gfx.y = x, y

    GUI.text_bg(output, self.bg)
    gfx.drawstr(output, 1)
    
end

                
function GUI.Slider:drawsliderhandle(hx, hy, hw, hh)

    for j = 1, GUI.shadow_dist do

        gfx.blit(self.buffs[2], 1, 0, hw + 2, 0, hw + 2, hh + 2, hx + j, hy + j)
        
    end

    --gfx.blit(source, scale, rotation[, srcx, srcy, srcw, srch, destx, desty, destw, desth, rotxoffs, rotyoffs] )

    gfx.blit(self.buffs[2], 1, 0, 0, 0, hw + 2, hh + 2, hx, hy) 
    
end


function GUI.Slider:drawcaption()

	GUI.font(self.font_a)
	
	local str_w, str_h = gfx.measurestr(self.caption)

	gfx.x = self.x + (self.w - str_w) / 2 + self.cap_x
	gfx.y = self.y - (self.dir ~= "v" and self.h or self.w) - str_h + self.cap_y
	GUI.text_bg(self.caption, self.bg)
	GUI.shadow(self.caption, self.col_txt, "shadow")
    
end




------------------------------------
-------- Slider helpers ------------
------------------------------------


function GUI.Slider:getnearesthandle(val)
    
	local small_diff, small_idx
	
	for i = 1, #self.handles do

		local diff = math.abs( self.handles[i].curval - val )
	
		if not small_diff or (diff < small_diff) then
			small_diff = diff
			small_idx = i

		end
		
	end
    
    return small_idx
    
end


function GUI.Slider:setcurstep(sldr, step)

    local inc = (self.max - self.min) / self.steps 
    self.handles[sldr].curstep = step
    self.handles[sldr].curval = self.handles[sldr].curstep / self.steps
    self:setretval(sldr)
    
    
end


function GUI.Slider:setcurval(sldr, val)
   
    self.handles[sldr].curval = val
    self.handles[sldr].curstep = GUI.round(val * self.steps)
    self:setretval(sldr)
    
end


function GUI.Slider:setretval(sldr)
    
    local inc = (self.max - self.min) / self.steps    
    self.handles[sldr].retval = GUI.round(inc * self.handles[sldr].curstep + self.min)   
    
end
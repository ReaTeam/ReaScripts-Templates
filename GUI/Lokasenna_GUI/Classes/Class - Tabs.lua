--[[	Lokasenna_GUI - Tabs class
	
	---- User parameters ----

(name, z, x, y, tab_w, tab_h, opts[, pad])

Required:
z				Element depth, used for hiding and disabling layers. 1 is the highest.
x, y			Coordinates of top-left corner
tab_w, tab_h	Size of each tab
opts			Comma-separated string of tab names

Optional:
pad				Padding between tabs

Additional:
w, h			Overall width and height of the tab strip. These are determined
				automatically based on the number of tabs and their size.
				
bg				Color to be drawn underneath the tabs. Defaults to "elm_bg".
col_txt			Text color. Defaults to "txt".
col_tab_a		Active tab color. Defaults to "wnd_bg"
col_tab_b		Inactive tab color. Defaults to "tab_bg"
font_a			Active tab font. Defaults to 3.
font_b			Inactive tab font. Defaults to 4.

state			The current tab. Numbered from left to right, starting at 1.



Extra methods:
update_sets		Controls the z layers that are shown for each tab.

				Define z sets like so:
				(Only needs to be done once, at startup)

				GUI.elms.my_tabs:update_sets(
					{
							   __ z-layers shown on that tab
					  __ tab  /
					 /		  |
					 |		  v
					 v     
					[1] = {2, 3, 4}, 
					[2] = {2, 5, 6}, 
					[3] = {2, 7, 8},
					}
				)
				
				
				update_sets() will be called automatically when a tab is clicked, or if
				a new tab is set using GUI.Val.
				

				- z-layers not included in any set (z = 1, above) will always be active 
				  unless frozen/hidden manually
				- z-layers in multiple sets (z = 2, above) will be active on all of those tabs
				- Elements can have their z changed at any time, handy if you want to hide 
				  specific bits rather than the whole layer
				

GUI.Val()		Returns the active tab. Numbered from 1.
GUI.Val(new)	Sets the active tab. Numbered from 1.






]]--

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

GUI.Tabs = GUI.Element:new()
function GUI.Tabs:new(name, z, x, y, tab_w, tab_h, opts, pad)
	
	local Tab = {}
	
	Tab.name = name
	Tab.type = "Tabs"
	
	Tab.z = z
	GUI.redraw_z[z] = true	
	
	Tab.x, Tab.y = x, y
	Tab.tab_w, Tab.tab_h = tab_w, tab_h

	Tab.font_a, Tab.font_b = 3, 4
	
	Tab.bg = "elm_bg"
	Tab.col_txt = "txt"
	Tab.col_tab_a = "wnd_bg"
	Tab.col_tab_b = "tab_bg"
	
    -- Placeholder for if I ever figure out downward tabs
	Tab.dir = "u"
	
	Tab.pad = pad
	
	-- Parse the string of options into a table
	Tab.optarray = {}
	local tempidx = 1
	for word in string.gmatch(opts, '([^,]+)') do
		Tab.optarray[tempidx] = word
		tempidx = tempidx + 1
	end
	
	Tab.numopts = tempidx - 1
	
	Tab.z_sets = {}
	for i = 1, Tab.numopts do
		Tab.z_sets[i] = {}
	end
	
	-- Figure out the total size of the Tab frame now that we know the 
    -- number of buttons, so we can do the math for clicking on it
	Tab.w, Tab.h = (tab_w + pad) * Tab.numopts, tab_h


	-- Currently-selected option
	Tab.retval, Tab.state = 1, 1

	setmetatable(Tab, self)
	self.__index = self
	return Tab

end


function GUI.Tabs:init()
    
    self:update_sets()    
    
end


function GUI.Tabs:draw()
	
	local x, y, w, h = self.x + 16, self.y, self.tab_w, self.tab_h
	local pad = self.pad
	local font = self.font_b
	local dir = self.dir
	local state = self.state
	local optarray = self.optarray

	GUI.color(self.bg)
	gfx.rect(x - 16, y, self.w + 32, self.h, true)
			
	local x_adj = w + pad
	
	-- Draw the inactive tabs first
	for i = self.numopts, 1, -1 do

		if i ~= state then
			--											 
			local tab_x, tab_y = x + GUI.shadow_dist + (i - 1) * x_adj, 
								 y + GUI.shadow_dist * (dir == "u" and 1 or -1)

			self:draw_tab(tab_x, tab_y, w, h, dir, font, self.col_txt, self.col_tab_b, optarray[i])

		end
	
	end

	self:draw_tab(x + (state - 1) * x_adj, y, w, h, dir, self.font_a, self.col_txt, self.col_tab_a, optarray[state])
	
	GUI.color(self.bg)
	gfx.line(x - 16, y, x + self.w + 16, y, 1)

	-- Cover up the bottom of the tabs
	GUI.color("wnd_bg")		
	gfx.rect(self.x, self.y + (dir == "u" and h or -6), (self.w + self.h), 6, true)

	
end


function GUI.Tabs:val(newval)
	
	if newval then
		self.state = newval
		self.retval = self.state

		self:update_sets()
		GUI.redraw_z[self.z] = true
	else
		return self.state
	end
	
end




------------------------------------
-------- Input methods -------------
------------------------------------


function GUI.Tabs:onmousedown()

    -- Offset for the first tab
	local adj = 0.75*self.h

	local mouseopt = (GUI.mouse.x - (self.x + adj)) / self.w
		
	mouseopt = GUI.clamp((math.floor(mouseopt * self.numopts) + 1), 1, self.numopts)

	self.state = mouseopt

	GUI.redraw_z[self.z] = true
	
end


function GUI.Tabs:onmouseup()
		
	-- Set the new option, or revert to the original if the cursor isn't inside the list anymore
	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) then
        
		self.retval = self.state		
		self:update_sets()
		
	else
		self.state = self.retval	
	end
    
	GUI.redraw_z[self.z] = true	
    
end


function GUI.Tabs:ondrag() 

	self:onmousedown()
	GUI.redraw_z[self.z] = true
    
end


function GUI.Tabs:onwheel()

	self.state = GUI.round(self.state + GUI.mouse.inc)
	
	if self.state < 1 then self.state = 1 end
	if self.state > self.numopts then self.state = self.numopts end
	
	self.retval = self.state
	self:update_sets()
	GUI.redraw_z[self.z] = true
    
end




------------------------------------
-------- Drawing helpers -----------
------------------------------------


function GUI.Tabs:draw_tab(x, y, w, h, dir, font, col_txt, col_bg, lbl)

	local dist = GUI.shadow_dist
    local y1, y2 = table.unpack(dir == "u" and  {y, y + h}
                                           or   {y + h, y})

	GUI.color("shadow")

    -- Tab shadow
    for i = 1, dist do
        
        gfx.rect(x + i, y, w, h, true)
        
        gfx.triangle(   x + i, y1, 
                        x + i, y2, 
                        x + i - (h / 2), y2)
        
        gfx.triangle(   x + i + w, y1,
                        x + i + w, y2,
                        x + i + w + (h / 2), y2)

    end

    -- Hide those gross, pixellated edges
    gfx.line(x + dist, y1, x + dist - (h / 2), y2, 1)
    gfx.line(x + dist + w, y1, x + dist + w + (h / 2), y2, 1)

    GUI.color(col_bg)

    gfx.rect(x, y, w, h, true)

    gfx.triangle(   x, y1,
                    x, y2,
                    x - (h / 2), y2)
                    
    gfx.triangle(   x + w, y1,
                    x + w, y2,
                    x + w + (h / 2), y + h)

    gfx.line(x, y1, x - (h / 2), y2, 1)
    gfx.line(x + w, y1, x + w + (h / 2), y2, 1)    
    
    
	-- Draw the tab's label
	GUI.color(col_txt)
	GUI.font(font)
	
	local str_w, str_h = gfx.measurestr(lbl)
	gfx.x = x + ((w - str_w) / 2)
	gfx.y = y + ((h - str_h) / 2) - 2 -- Don't include the bit we drew under the frame
	gfx.drawstr(lbl)	

end




------------------------------------
-------- Tab helpers ---------------
------------------------------------


-- Updates visibility for any layers assigned to the tabs
function GUI.Tabs:update_sets(init)
    
	local state = self.state
	
	if init then
		self.z_sets = init
	end

	local z_sets = self.z_sets

	if not z_sets or #z_sets[1] < 1 then
		reaper.ShowMessageBox("GUI element '"..self.name.."':\nNo z sets found.", "Library error", 0)
		GUI.quit = true
		return 0
	end

	for i = 1, #z_sets do
        
        local hide = (i ~= state)
        for tab, z in pairs(z_sets[i]) do
            
            GUI.elms_hide[z] = hide
            
        end
	end

end

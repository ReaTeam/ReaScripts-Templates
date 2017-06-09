--[[	Lokasenna_GUI - Label class.

	---- User parameters ----
	
	(name, z, x, y, caption[, shadow, font, color, bg])
	
Required:
z				Element depth, used for hiding and disabling layers. 1 is the highest.
x, y			Coordinates of top-left corner
caption			Label text

Optional:
shadow			Boolean. Draw a shadow?
font			Which of the GUI's font values to use
color			Use one of the GUI.colors keys to override the standard text color
bg				Color to be drawn underneath the label. Defaults to "wnd_bg"

Additional:
w, h			These are set when the Label is initially drawn, and updated any
				time the label's text is changed via GUI.Val().

Extra methods:
fade			Allows a label to fade out and disappear. Nice for briefly displaying
				a status message like "Saved to disk..."

				Params:
				len			Length of the fade, in seconds
				z_new		z layer to move the label to when called
							i.e. popping up a tooltip
				z_end		z layer to move the label to when finished
							i.e. putting the tooltip label back in a
							frozen layer until you need it again
							
							Set to -1 to have the label deleted instead
				
				curve		Optional. Sets the "shape" of the fade.
							
							1 	will produce a linear fade
							>1	will keep the text at full-strength longer,
								but with a sharper fade at the end
							<1	will drop off very steeply
							
							Defaults to 3 if not specified
							
				Note: While fading, the label's z layer will be redrawn on every
				update loop, which may affect CPU usage for scripts with many elements
							  
]]--

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end


-- Label - New
GUI.Label = GUI.Element:new()
function GUI.Label:new(name, z, x, y, caption, shadow, font, color, bg)
	
	local label = {}	
	
	label.name = name
	
	label.type = "Label"
	
	label.z = z
	GUI.redraw_z[z] = true

	label.x, label.y = x, y
	
	label.w, label.h = 0, 0
	
	label.retval = caption
	
	label.shadow = shadow or false
	label.font = font or 2
	
	label.color = color or "txt"
	label.bg = bg or "wnd_bg"
	
	setmetatable(label, self)
    self.__index = self 
    return label
	
end


function GUI.Label:fade(len, z_new, z_end, curve)
	
	self.z = z_new
	self.fade_arr = { len, z_end, reaper.time_precise(), curve or 3 }
	GUI.redraw_z[self.z] = true
	
end


-- Label - Draw
function GUI.Label:draw()
	
	local x, y = self.x, self.y
		
	GUI.font(self.font)
	GUI.color(self.color)
	
	if self.fade_arr then
		
		-- Seconds for fade effect, roughly
		local fade_len = self.fade_arr[1]
		
		local diff = (reaper.time_precise() - self.fade_arr[3]) / fade_len
		diff = math.floor(diff * 100) / 100
		diff = diff^(self.fade_arr[4])
		local a = 1 - (gfx.a * (diff))
		
		GUI.redraw_z[self.z] = true
		if a < 0.02 then
			self.z = self.fade_arr[2]
			self.fade_arr = nil
			return 0 
		end
		gfx.set(gfx.r, gfx.g, gfx.b, a)
	end

	gfx.x, gfx.y = x, y

	GUI.text_bg(self.retval, self.bg)

	if self.h == 0 then	
		self.w, self.h = gfx.measurestr(self.retval)
	end
	
	if self.shadow then	
		GUI.shadow(self.retval, self.color, "shadow")
	else
		gfx.drawstr(self.retval)
	end	

end


-- Label - Get/set value
function GUI.Label:val(newval)

	if newval then
		self.retval = newval
		GUI.font(self.font)
		self.w, self.h = gfx.measurestr(self.retval)
		GUI.redraw_z[self.z] = true
	else
		return self.retval
	end

end


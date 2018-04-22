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
                            
                            Use negative values to fade in on z_new, rather
                            than fading out. In this case, the value of
                            z_end doesn't matter.
							

							
				Note: While fading, the label's z layer will be redrawn on every
				update loop, which may affect CPU usage for scripts with many elements.
                
                If this is the case, try to put the label on a layer with as few
                other elements as possible.
							  
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
	
    -- Placeholders; we'll get these at runtime
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


function GUI.Label:init(open)

    -- We can't do font measurements without an open window
    if gfx.w == 0 then return end
    
    self.buffs = self.buffs or GUI.GetBuffer(2)

    GUI.font(self.font)
    self.w, self.h = gfx.measurestr(self.retval) 

    local w, h = self.w + 4, self.h + 4

    -- Because we might be doing this in mid-draw-loop,
    -- make sure we put this back the way we found it
    local dest = gfx.dest


    -- Keeping the background separate from the text to avoid graphical
    -- issues when the text is faded.
    gfx.dest = self.buffs[1]
    gfx.setimgdim(self.buffs[1], -1, -1)
    gfx.setimgdim(self.buffs[1], w, h)
    
    GUI.color(self.bg)
    gfx.rect(0, 0, w, h)

    -- Text + shadow
    gfx.dest = self.buffs[2]
    gfx.setimgdim(self.buffs[2], -1, -1)
    gfx.setimgdim(self.buffs[2], w, h)

    -- Text needs a background or the antialiasing will look like shit
    GUI.color(self.bg)
    gfx.rect(0, 0, w, h)

    gfx.x, gfx.y = 2, 2

    GUI.color(self.color)

	if self.shadow then	
        GUI.shadow(self.retval, self.color, "shadow")
    else
        gfx.drawstr(self.retval)
    end   
    
    gfx.dest = dest
    
end


function GUI.Label:fade(len, z_new, z_end, curve)
	
	self.z = z_new
	self.fade_arr = { len, z_end, reaper.time_precise(), curve or 3 }
	GUI.redraw_z[self.z] = true
	
end


function GUI.Label:draw()
	
    -- Font stuff doesn't work until we definitely have a gfx window
	if self.w == 0 then self:init() end

    local a = self.fade_arr and self:getalpha() or 1
    if a == 0 then return end

    gfx.x, gfx.y = self.x - 2, self.y - 2
    
    -- Background
    gfx.blit(self.buffs[1], 1, 0)
    
    gfx.a = a
    
    -- Text
    gfx.blit(self.buffs[2], 1, 0)

    gfx.a = 1
    
end


function GUI.Label:val(newval)

	if newval then
		self.retval = newval
		self:init()
		GUI.redraw_z[self.z] = true
	else
		return self.retval
	end

end


function GUI.Label:getalpha()
    
    local sign = self.fade_arr[4] > 0 and 1 or -1
    
    local diff = (reaper.time_precise() - self.fade_arr[3]) / self.fade_arr[1]
    diff = math.floor(diff * 100) / 100
    diff = diff^(math.abs(self.fade_arr[4]))
    
    local a = sign > 0 and (1 - (gfx.a * diff)) or (gfx.a * diff)

    GUI.redraw_z[self.z] = true
    
    -- Terminate the fade loop at some point
    if sign == 1 and a < 0.02 then
        self.z = self.fade_arr[2]
        self.fade_arr = nil
        return 0
    elseif sign == -1 and a > 0.98 then
        self.fade_arr = nil
    end

    return a
    
end
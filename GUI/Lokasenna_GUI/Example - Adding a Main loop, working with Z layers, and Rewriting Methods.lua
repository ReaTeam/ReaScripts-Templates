--[[
	Lokasenna_GUI 2.0 preview

	- Using the Main loop to monitor and interact with things in Reaper
	- Using z layers and related functions to move elements around
	- Changing elements' methods for your own purposes

]]--

local dm, _ = debug_mode
local function Msg(str)
	reaper.ShowConsoleMsg(tostring(str).."\n")
end

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]


-- I hate working with 'requires', so I've opted to do it this way.
-- This also works much more easily with my Script Compiler.
local function req(file)
	
	if missing_lib then return function () end end
	
	local ret, err = loadfile(script_path .. file)
	if not ret then
		reaper.ShowMessageBox("Couldn't load "..file.."\n\nError: "..tostring(err), "Library error", 0)
		missing_lib = true		
		return function () end

	else 
		return ret
	end	

end


req("Core.lua")()

-- The Core library must be loaded prior to any classes, or the classes will throw up errors.
req("Classes\\Class - Label.lua")()
--req("Classes\\Class - Knob.lua")()
--req("Classes\\Class - Tabs.lua")()
req("Classes\\Class - Slider.lua")()
--req("Classes\\Class - Button.lua")()
--req("Classes\\Class - Menubox.lua")()
--req("Classes\\Class - Checklist.lua")()
--req("Classes\\Class - Radio.lua")()
--req("Classes\\Class - Textbox.lua")()
req("Classes\\Class - Frame.lua")()

if missing_lib then return 0 end



GUI.name = "Example - Main, Z, and Methods"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 300, 128
GUI.anchor, GUI.corner = "mouse", "C"


-- Pre-declaring this so every function has access to it
local tr



--[[	

	New elements are created by:
	
	GUI.New(name, class, params)
	
	and can then have their parameters accessed via:
	
	GUI.elms.name.param
	
	ex:
	
	GUI.New("my_new_label", "Label", 1, 32, 32, "This is my label")
	GUI.elms.my_new_label.color = "magenta"
	GUI.elms.my_new_label.font = 1
	
	
		Classes and parameters
	
	Button		name, 	z, 	x, 	y, 	w, 	h, caption, func[, ...]
	Checklist	name, 	z, 	x, 	y, 	w, 	h, caption, opts[, dir, pad]
	Frame		name, 	z, 	x, 	y, 	w, 	h[, shadow, fill, color, round]
	Knob		name, 	z, 	x, 	y, 	w, 	caption, min, max, steps, default[, vals]	
	Label		name, 	z, 	x, 	y,		caption[, shadow, font, color, bg]
	Menubox		name, 	z, 	x, 	y, 	w, 	h, caption, opts
	Radio		name, 	z, 	x, 	y, 	w, 	h, caption, opts[, dir, pad]
	Slider		name, 	z, 	x, 	y, 	w, 	caption, min, max, steps, handles[, dir]
	Tabs		name, 	z, 	x, 	y, 		tab_w, tab_h, opts[, pad]
	Textbox		name, 	z, 	x, 	y, 	w, 	h[, caption, pad]

	
]]--

GUI.New("lbl_track", "Label",	1,	96, 8, "No track selected!", true, 2, "red")
GUI.New("frm_track", "Frame",	2,	0, 0, 300, 128, false, true, "faded", 0)
GUI.New("sldr_pan", "Slider",	3,	88, 64, 128, "First selected track's Pan:", -100, 100, 200, 100, "h")

-- Layer 5 will never be shown or updated
-- (See the Main function below)
GUI.elms_hide[5] = true



local function update_pan()
	
	reaper.SetMediaTrackInfo_Value( tr, "D_PAN", GUI.Val("sldr_pan")/100 )
	
end


-- Class methods can be overwritten, either at the class level or
-- for individual elements.

-- You can also easily add your own code to methods:

-- Needs to be global, since GUI already exists
function GUI.elms.sldr_pan:onmousedown()
	
	-- Run the slider's normal method
	
	-- Note that we have to call the method as a function here; we
	-- can't use the : syntax because sldr_pan's 'self' needs to be
	-- passed on as a value. If we used a :, it would pass GUI.Slider
	GUI.Slider.onmousedown(self)
	update_pan()
	
end
function GUI.elms.sldr_pan:ondrag()
	GUI.Slider.ondrag(self)
	update_pan()
end
function GUI.elms.sldr_pan:onwheel()
	GUI.Slider.onwheel(self)
	update_pan()
end
function GUI.elms.sldr_pan:ondoubleclick()
	GUI.Slider.ondoubleclick(self)
	update_pan()
end



-- This will be run on every update loop of the GUI script; anything you would put
-- inside a reaper.defer() loop should go here. (The function name doesn't matter)
local function Main()
	
	-- Check the track state and toggle our warning label as needed
	tr = reaper.GetSelectedTrack( 0, 0 )
	
	if tr then
		
		-- Save a bit of CPU by only doing this if we need to
		if GUI.elms.lbl_track.z == 1 then
			
			-- These both accomplish the same thing...
			
			-- lbl_track is moved to a different layer, which we've permanently
			-- hidden above. Use this if you have several elements on a single 
			-- layer and only want to hide one of them. e.g. adjusting which
			-- options are available depending on other things the user does.
			GUI.elms.lbl_track.z = 5
			
			-- frm_track's entire layer is hidden. This is what the Tabs element
			-- uses.
			GUI.elms_hide[GUI.elms.frm_track.z] = true
			
			
			-- Layers can also be frozen; they'll be drawn, but won't receive
			-- any user input. Use this for i.e. having a slider display an
			-- RMS value, since the user can't do anything with it.
			
			-- Completely unnecessary here, because frm_track is on top and will
			-- "steal" any user input.
			
			GUI.elms_freeze[GUI.elms.sldr_pan.z] = false
			
			
			-- Force a redraw of every layer
			GUI.redraw_z[0] = true
			
		end
		
		-- See if the track's Pan value has been changed and update the slider
		local pan = reaper.GetMediaTrackInfo_Value( tr, "D_PAN" )
		if math.abs( pan - (GUI.Val("sldr_pan") / 100) ) > 0.00 then
			
			-- Converting the returned value (-1 to 1) to Slider steps (0 to 200)
			pan = (math.floor(100*pan) - GUI.elms.sldr_pan.min )
			
			-- Pan knobs can actually be at 0% L or R; correcting for that.
			if pan < 100 then pan = pan + 1 end
			
			GUI.Val("sldr_pan", pan )
			
		end		
		
	else
	
		if GUI.elms.lbl_track.z == 5 then
			
			GUI.elms.lbl_track.z = 1
			GUI.elms_hide[GUI.elms.frm_track.z] = false
			GUI.elms_freeze[GUI.elms.sldr_pan.z] = true
		
			GUI.redraw_z[0] = true
			
		end
	
	end
	
	
end

GUI.Init()

-- Tell the GUI library to run Main on each update loop
-- Individual elements are updated first, then GUI.func is run, then the GUI is redrawn
GUI.func = Main

-- How often (in seconds) to run GUI.func. 0 = every loop.
GUI.freq = 0

GUI.Main()
--[[
	Lokasenna_GUI 2.0
	
	-- Tabs and layer sets
	-- Accessing elements' parameters

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


-- The Core library must be loaded prior to any classes, or the classes will throw up errors
-- when they look for functions that aren't there.
req("Core.lua")()

req("Classes/Class - Label.lua")()
req("Classes/Class - Knob.lua")()
req("Classes/Class - Tabs.lua")()
req("Classes/Class - Slider.lua")()
req("Classes/Class - Button.lua")()
req("Classes/Class - Menubox.lua")()
req("Classes/Class - Checklist.lua")()
req("Classes/Class - Radio.lua")()
req("Classes/Class - Textbox.lua")()
req("Classes/Class - Frame.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end


GUI.name = "New Window"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 432, 500
GUI.anchor, GUI.corner = "mouse", "C"


local function btn_click()
	
	--reaper.ShowMessageBox("Yay, you clicked a button. Now what?", "<(^^<)", 0)
	
	local tab_num = GUI.Val("tabs")
	Msg("Displaying values for tab "..tostring(tab_num))
	
	-- The '+ 2' here is just to translate from a tab number to its' 
	-- associated z layer. More complicated scripts would have to 
	-- actually access GUI.elms.tabs.z_sets[tab_num] and iterate over
	-- the table's contents (see the call to GUI.elms.tabs:update_sets
	-- below)
	for k, v in pairs(GUI.elms_list[tab_num + 2]) do
		
		local val = GUI.Val(v)
		if type(val) == "table" then
			local str = ""
			for i = 1, #val do
				str = str..", "..tostring(val[i])
			end
			val = string.sub(str, 3)
		end
		Msg("\t"
			..tostring(v)
			.."\t\t"
			..tostring(val)
		   )
		
	end
	
end

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
	Listbox		name, 	z, 	x, 	y, 	w, 	h, list[, multi, shadow]
	
]]--


GUI.New("tabs", 	"Tabs", 		1, 0, 0, 64, 20, "Tab 1,Tab 2,Tab 3", 16)
GUI.New("tab_bg",	"Frame",		2, 0, 0, 448, 20, true, true, "elm_bg", 0)

-- Telling the tabs which z layers to display
-- See Classes/Tabs.lua for more detail
GUI.elms.tabs:update_sets(
	--  Tab
	--			Layers
	{	[1] =	{3},
		[2] =	{4},
		[3] =	{5},
	}
)

-- Notice that layers 1 and 2 aren't assigned to a tab; this leaves them visible
-- all the time.

GUI.New("my_btn", 	"Button", 		1, 168, 28, 96, 20, "Go!", btn_click)
GUI.New("btn_frm",	"Frame",		1, 0, 56, GUI.w, 4, true, true)

GUI.New("my_lbl", 	"Label", 		3, 256, 96, "Label!", true, 1)
GUI.New("my_knob", 	"Knob", 		3, 64, 112, 64, "Volume", 0, 11, 12, 12, 1)

-- Adding a suffix to the knob's values
GUI.elms.my_knob.output = function(val)
	
	return tostring(val).."dB"
	
end

GUI.New("my_mnu", 	"Menubox", 		3, 256, 176, 64, 20, "Options:", "1,2,3,4,5,6")
GUI.New("my_txt", 	"Textbox", 		3, 96, 224, 96, 20, "Text:", 4)
GUI.New("my_frm", 	"Frame", 		3, 16, 288, 192, 128, true, true, "elm_bg", 4)
GUI.elms.my_frm.text = "this is a really long string of text with no carriage returns so hopefully it will be wrapped correctly to fit inside this frame"

GUI.New("my_rng", 	"Slider", 		4, 32, 128, 256, "Sliders", 0, 30, 30, {5, 10, 15, 20, 25})
GUI.New("my_sldr", 	"Slider",		4, 32, 192, 256, "Slider", 0, 30, 30, 15)
GUI.New("my_pan", 		"Slider", 		4, 32, 256, 256, "Pan", -100, 100, 200, 100)

-- Using a function to change the value label depending on the value
GUI.elms.my_pan.output = function(val)
	
	val = tonumber(val)
	return (val == 0	and "0" 
						or	(math.abs(val)..	
							(val < 0 and "L" or "R") 
							) 
			)
	
end

GUI.New("my_rng2", 	"Slider",		4, 352, 96, 256, "Vertical?", 0, 30, 30, {5, 10, 15, 20, 25}, "v")

GUI.New("my_chk", 	"Checklist", 	5, 32, 96, 160, 160, "Checklist:", "Alice,Bob,Charlie,Denise,Edward", "v", 4)
GUI.New("my_opt", 	"Radio", 		5, 200, 96, 160, 160, "Options:", "Apples,Bananas,Cherries,Donuts,Eggplant", "v", 4)
GUI.New("my_chk2",	"Checklist",	5, 32, 280, 384, 64, "Whoa, another Checklist", "N,NE,E,SE,S,SW,W,NW", "h", 4)
GUI.New("my_opt2",	"Radio",		5, 32, 364, 384, 64, "Horizontal options", "A,A#,B,C,C#,D,D#,E,F,F#,G,G#", "h", 4)



-- This will be run on every update loop of the GUI script; anything you would put
-- inside a reaper.defer() loop should go here. (The function name doesn't matter)
local function Main()
	
	-- Prevent the user from resizing the window
	if GUI.resized then
		
		-- If the window's size has been changed, reopen it
		-- at the current position with the size we specified
		local __,x,y,w,h = gfx.dock(-1,0,0,0,0)
		gfx.quit()
		gfx.init(GUI.name, GUI.w, GUI.h, 0, x, y)
		GUI.redraw_z[0] = true
	end		
	
end


GUI.Init()

-- Tell the GUI library to run Main on each update loop
-- Individual elements are updated first, then GUI.func is run, then the GUI is redrawn
GUI.func = Main

-- How often (in seconds) to run GUI.func. 0 = every loop.
GUI.freq = 0


GUI.Main()
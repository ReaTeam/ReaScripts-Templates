--[[
	Lokasenna_GUI 2.0 preview
	
	- Getting user input before running an action; i.e. replacing GetUserInputs

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
req("Classes\\Class - Knob.lua")()
req("Classes\\Class - Tabs.lua")()
req("Classes\\Class - Slider.lua")()
req("Classes\\Class - Button.lua")()
req("Classes\\Class - Menubox.lua")()
req("Classes\\Class - Checklist.lua")()
req("Classes\\Class - Radio.lua")()
req("Classes\\Class - Textbox.lua")()
req("Classes\\Class - Frame.lua")()

if missing_lib then return 0 end



GUI.name = "Example - Script template"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 400, 200
GUI.anchor, GUI.corner = "mouse", "C"

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

GUI.New("mnu_mode",	"Menubox",		1, 64,	32,  72, 20, "Mode:", "Auto,Punch,Step")
GUI.New("chk_opts",	"Checklist",	1, 192,	32,  192, 96, "Options", "Only in time selection,Only on selected track,Glue items when finished", "v", 4)
GUI.New("sldr_thresh", "Slider",	1, 32,  96, 128, "Threshold", -500, 0, 500, 482, "h")
GUI.New("btn_go",	"Button",		1, 168, 152, 64, 24, "Go!", btn_click)

GUI.Init()
GUI.Main()
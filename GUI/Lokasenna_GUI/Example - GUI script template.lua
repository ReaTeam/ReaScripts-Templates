--[[
	Lokasenna_GUI 2.0

	- Blank GUI template

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

req("Classes/Class - Slider.lua")()
req("Classes/Class - Button.lua")()
req("Classes/Class - Menubox.lua")()
req("Classes/Class - Checklist.lua")()


-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end




------------------------------------
-------- GUI Stuff -----------------
------------------------------------


GUI.name = "Example - Script template"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 400, 200
GUI.anchor, GUI.corner = "mouse", "C"

--[[	

	Button		z, 	x, 	y, 	w, 	h, caption, func[, ...]
	Checklist	z, 	x, 	y, 	w, 	h, caption, opts[, dir, pad]
	Menubox		z, 	x, 	y, 	w, 	h, caption, opts[, pad, noarrow]
	Slider		z, 	x, 	y, 	w, 	caption, min, max, steps, handles[, dir]
	
]]--

GUI.New("mnu_mode",	"Menubox",		1, 64,	32,  72, 20, "Mode:", "Auto,Punch,Step")
GUI.New("chk_opts",	"Checklist",	1, 192,	32,  192, 96, "Options", "Only in time selection,Only on selected track,Glue items when finished", "v", 4)
GUI.New("sldr_thresh", "Slider",	1, 32,  96, 128, "Threshold", -500, 0, 500, 482, "h")
GUI.New("btn_go",	"Button",		1, 168, 152, 64, 24, "Go!", btn_click)

GUI.Init()
GUI.Main()
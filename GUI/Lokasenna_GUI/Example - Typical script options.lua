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
--req("Classes\\Class - Label.lua")()
--req("Classes\\Class - Knob.lua")()
--req("Classes\\Class - Tabs.lua")()
req("Classes\\Class - Slider.lua")()
req("Classes\\Class - Button.lua")()
req("Classes\\Class - Menubox.lua")()
req("Classes\\Class - Checklist.lua")()
--req("Classes\\Class - Radio.lua")()
--req("Classes\\Class - Textbox.lua")()
--req("Classes\\Class - Frame.lua")()

if missing_lib then return 0 end



GUI.name = "Example - Typical script options"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 400, 200
GUI.anchor, GUI.corner = "mouse", "C"


local function btn_click()
	
	-- Grab all of the user's settings into local variables,
	-- just to make it less awkward to work with
	local mode, thresh = GUI.Val("mnu_mode"), GUI.Val("sldr_thresh")
	local opts = GUI.Val("chk_opts")
	local time_sel, sel_track, glue = opts[1], opts[2], opts[3]
	
	-- Be nice, give the user an Undo point
	reaper.Undo_BeginBlock()
	
	reaper.ShowMessageBox(
		"This is where we pretend to perform some sort of fancy operation with the user's settings.\n\n"
		.."Working in "..tostring(GUI.elms.mnu_mode.optarray[mode])
		.." mode with a threshold of "..tostring(thresh).."db.\n\n"
		.."Apply only to time selection: "..tostring(time_sel).."\n"
		.."Apply only to selected track: "..tostring(sel_track).."\n"
		.."Glue the processed items together afterward: "..tostring(glue)
	, "Yay!", 0)
	
	
	reaper.Undo_EndBlock("Typical script options", 0)	
	
	-- Exit the script on the next update
	GUI.quit = true
	
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

	
]]--

GUI.New("mnu_mode",	"Menubox",		1, 64,	32,  72, 20, "Mode:", "Auto,Punch,Step")
GUI.New("chk_opts",	"Checklist",	1, 192,	32,  192, 96, "Options", "Only in time selection,Only on selected track,Glue items when finished", "v", 4)
GUI.New("sldr_thresh", "Slider",	1, 32,  96, 128, "Threshold", -60, 0, 60, 48, "h")
GUI.New("btn_go",	"Button",		1, 168, 152, 64, 24, "Go!", btn_click)

GUI.Init()
GUI.Main()
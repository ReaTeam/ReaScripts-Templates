-- Grab all of the functions and classes from our GUI library
local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
GUI = loadfile(script_path .. "Lokasenna_GUI Library beta 1.lua")

if not GUI then
	reaper.ShowMessageBox( "This script requires Lokasenna's GUI library to run.\nPlease make sure 'Lokasenna_GUI Library beta 1.lua' is in the same folder.", "Library not found", 0)
	return 0
else
	GUI = GUI()
end

-- All functions in the GUI library are now contained in the GUI table,
-- so they can be accessed via:		GUI.function(params)




	---- Window settings and user functions ----


GUI.name = "Lokasenna_GUI example"
GUI.x, GUI.y, GUI.w, GUI.h = 200, 200, 640, 480


-- Example of a user function that we'll run from a button
function userfunc(str)
	
	
	gfx.x, gfx.y = GUI.mouse.x, GUI.mouse.y

	gfx.showmenu(str)
	
end


--[[	---- Font/color presets ----
	
	Only necessary if you want to override the defaults
	
	GUI.fonts = {
	
		Font, size, bold, italics, underline
		(Currently can only use one of B / I / U per font)
		
		{"Calibri", 36, 1, 0, 0},	-- 1. Title
		{"Calibri", 28, 0, 0, 0},	-- 2. Header
		{"Calibri", 22, 0, 0, 0},	-- 3. Label
		{"Calibri", 18, 0, 0, 0}	-- 4. Value
		
	}

	GUI.colors = {
		
				  R,  G,  B,  A
		wnd_bg = {64, 64, 64, 1},			-- Window BG
		elm_bg = {48, 48, 48, 1},			-- Element BG
		elm_frame = {96, 96, 96, 1},		-- Element Frame
		elm_fill = {64, 192, 64, 1},		-- Element Fill
		elm_outline = {32, 32, 32, 1},
		txt = {192, 192, 192, 1},			-- Text
		
		shadow = {0, 0, 0, 0.6}				-- Shadow

	}
	
	--Global shadow size, in pixels
	GUI.shadow_dist = 2
]]--


	---- GUI Elements ----
	
--[[	Classes and parameters
		(see comments in LS GUI.lua for more thorough documentation)
		
	Label		x y		caption		shadow
	Button		x y w h caption
	Radio		x y w h caption 	opts	pad
	Checklist	x y w h caption 	opts	pad
	Knob		x y w	caption 	min 	max		steps	default		ticks
	Slider		x y w	caption 	min 	max 	steps 	default
	Range		x y w	caption		min		max		steps 	default_a 	default_b
	Textbox		x y w h	caption		pad
	Menubox		x y w h caption		opts	pad
	
	Example:
	
	GUI.elms = {
	
	my_textbox	= GUI.Textbox:new(	340, 210, 200, 30, "Favorite book:", 4),
										(make sure you include the comma) ^^^
	
	}
	
	
]]--

GUI.elms = {
	
--	name		= element type		x	 y    w    h	caption			...other params...
	label 		= GUI.Label:new(	30,  30,			"Lokasenna_GUI Example:", 1),
	pan_sldr 	= GUI.Slider:new(	400, 200, 128, 		"Pan:", -100, 100, 201, 101, 0),
	vol_knb 	= GUI.Knob:new(		450, 300, 48,  		"Volume", -12, 3, 16, 13, 1),
	options 	= GUI.Radio:new(	50,  100, 150, 150, "Muppets:", "Cool,Dumb,Who?,Delicious", 4),
	range_sldr  = GUI.Range:new(	380, 50,  200, 		"Spread:", 0, 100, 101, 0, 101),
	list 		= GUI.Checklist:new(210, 100, 120, 150, "I like to eat:", "Fruit,Veggies,Meat,Dairy", 4),
	checkbox 	= GUI.Checklist:new(380, 410, 240, 30, 	"", "Are you a cool guy?", 4),
	my_btn	 	= GUI.Button:new(	400, 100, 100, 50, 	"CLICK ME", reaper.MB, "Stuff goes here!", "Like omg you guys", 6),
	text	 	= GUI.Textbox:new(	100, 300, 100, 24, 	"Favorite music player:", 4),
	newmenu		= GUI.Menubox:new(	160, 370, 150, 24, 	"Best AC/DC singer:", "Bon Scott,Brian Johnson,Axl Rose", 4),
		
}


	---- Put all of your own functions and whatever here ----


--[[
	
	If you want your function to end the script, i.e. "apply these changes and quit", use GUI.quit to
	make it exit on the next loop:
	
		GUI.quit = true
	
	
]]--




	---- Main loop ----
		

--[[
	
	If you want to run a function during the update loop, use the variable GUI.func prior to
	starting GUI.Main() loop:
	
		GUI.func = my_function
		GUI.freq = 5	<-- How often in seconds to run the function, so we can avoid clogging up the CPU.
							- Will run once a second if no value is given.
							- Integers only, 0 will run every time.
							
	
	If you'd like to perform a function when the script exits, such as saving the user's settings, etc,
	you can use GUI.exit:
	
		GUI.exit = save_my_settings
	
	
	
	GUI.Init()
	GUI.Main()
	
]]--


GUI.Init()
GUI.Main()
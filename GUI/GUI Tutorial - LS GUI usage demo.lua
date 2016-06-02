-- Grab all of the functions and classes from our GUI library
local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
GUI = dofile(script_path .. "GUI Tutorial - LS GUI library demo.lua")

-- All functions in the GUI library are now contained in the GUI table,
-- so they can be accessed via:		GUI.function(params)




	---- Window settings and user functions ----


GUI.name = "LS GUI Demo"
GUI.x, GUI.y, GUI.w, GUI.h = 200, 200, 640, 480


-- Example of a user function that we'll run from a button
function userfunc(str)
	
	
	gfx.x, gfx.y = GUI.mouse.x, GUI.mouse.y

	gfx.showmenu(str)
	
end




	---- GUI Elements ----
	
	
GUI.elms = {
	
--	name		= element type		x	 y    w    h	caption			...other params...
	label 		= GUI.Label:new(	30,  30,			"LS GUI Example:", 1),
	pan_sldr 	= GUI.Slider:new(	360, 280, 128, 		"Pan:", -100, 100, 200, 4),
	pan_knb 	= GUI.Knob:new(		400, 360, 48,  		"Pan", 0, 9, 10, 5, 1),
	options 	= GUI.Radio:new(	50,  100, 150, 150, "Color notes by:", "Channel,Pitch,Velocity,Penis Size", 4),
	blah 		= GUI.Radio:new(	50,  260, 250, 200, "I have a crush on:", "Justin F,schwa,X-Raym,Jason Brian Merrill,pipelineaudio,Xenakios", 2, 0),
	newlist 	= GUI.Checklist:new(210, 100, 120, 150, "I like to eat:", "Fruit,Veggies,Meat,Dairy", 4),
	checkers 	= GUI.Checklist:new(350, 440, 240, 30, 	"", "Are you a cool guy?", 4),
	testbtn 	= GUI.Button:new(	340, 100, 100, 50, 	"Ceci n'est pas\n  un bouton", reaper.MB, "Stuff goes here!", "Like omg you guys", 6),
	testbtn2 	= GUI.Button:new(	450, 100, 100, 50, 	"CLICK", userfunc, "This|#Is|A|!Menu"),
	newtext 	= GUI.Textbox:new(	340, 210, 200, 30, 	"Favorite music player:", 4),
		
}


	---- Put all of your own functions and whatever here ----




	---- Main loop ----

--[[
	
	If you want to run a function during the update loop, use the variable GUI.func prior to
	starting GUI.Main() loop:
	
	GUI.func = my_function
	GUI.freq = 5	<-- How often in seconds to run the function, so we can avoid clogging up the CPU.
						- Will run once a second if no value is given.
						- Integers only, 0 will run every time.
	
	GUI.Init()
	GUI.Main()
	
]]--


GUI.Init()
GUI.Main()
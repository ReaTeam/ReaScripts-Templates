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


-- Any user functions, font/color preset overrides go here


GUI.name = ""
GUI.x, GUI.y, GUI.w, GUI.h = 200, 200, 640, 480


	---- GUI Elements ----
	
--[[
	Label		x y		caption		shadow
	Button		x y w h caption
	Radio		x y w h caption 	opts	pad
	Checklist	x y w h caption 	opts	pad
	Knob		x y w	caption 	min 	max		steps	default		ticks
	Slider		x y w	caption 	min 	max 	steps 	default
	Range		x y w	caption		min		max		steps 	default_a 	default_b
	Textbox		x y w h	caption		pad
	Menubox		x y w h caption		opts	pad
]]--


GUI.elms = {


}


reaper.Undo_BeginBlock()


-- Do whatever you need to do here


GUI.Init()
GUI.Main()

reaper.Undo_EndBlock("", -1)
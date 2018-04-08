--[[
	Lokasenna_GUI 2.0
	
	- Demonstration of the Listbox and TextEditor classes

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

req("Classes/Class - Button.lua")()
req("Classes/Class - Listbox.lua")()
req("Classes/Class - TextEditor.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end


local items = {
	
	{"Pride and Prejudice", 
[[It is a truth universally acknowledged, that a single man in possession of a good fortune
must be in want of a wife.]]},

	{"100 Years of Solitude", 
[[Many years later, as he faced the firing squad, Colonel Aureliano Buendía was to remember
that distant afternoon when his father took him to discover ice.]]},

	{"Lolita", 
[[Lolita, light of my life, fire of my loins.]]},

	{"1984", 
[[It was a bright cold day in April, and the clocks were striking thirteen.]]},
	
	{"A Tale of Two Cities", 
[[It was the best of times, it was the worst of times, it was the age of wisdom, it was the
age of foolishness, it was the epoch of belief, it was the epoch of incredulity, it was the
season of Light, it was the season of Darkness, it was the spring of hope, it was the winter
of despair.]]},
	
	{"The Catcher in the Rye", 
[[If you really want to hear about it, the first thing you’ll probably want to know is where
I was born, and what my lousy childhood was like, and how my parents were occupied and all
before they had me, and all that David Copperfield kind of crap, but I don’t feel like going
into it, if you want to know the truth.]]},
	
	{"City of Glass", 
[[It was a wrong number that started it, the telephone ringing three times in the dead of
night, and the voice on the other end asking for someone he was not.]]},
	
	{"The Stranger", 
[[Mother died today.]]},
	
	{"Waiting", 
[[Every summer Lin Kong returned to Goose Village to divorce his wife, Shuyu.]]},
	
	{"Notes from Underground", 
[[I am a sick man . . . I am a spiteful man.]]},
	
	{"Paradise", 
[[They shoot the white girl first.]]},
	
	{"The Old Man and the Sea", 
[[He was an old man who fished alone in a skiff in the Gulf Stream and he had gone
eighty-four days now without taking a fish.]]},
	
	{"The Crow Road", 
[[It was the day my grandmother exploded.]]},
	
	{"Catch-22", 
[[It was love at first sight.]]},
	
	{"Imaginative Qualities of Actual Things",
[[What if this young woman, who writes such bad poems, in competition with her husband,
whose poems are equally bad, should stretch her remarkably long and well-made legs out
before you, so that her skirt slips up to the tops of her stockings?]]}

}



local function add_text()
	
	-- Get the list box's selected item(s)
	local selected = GUI.Val("lst_titles")
	
	-- Make sure it's a table, just to be consistent with the multi-select logic
	if type(selected) == "number" then selected = {[selected] = true} end
	
	-- Get and sort the selected item numbers
	local vals = {}
	for k, v in pairs(selected) do
		table.insert(vals, k)
	end
	
	table.sort(vals)
	
	-- Replace the numbers with the appropriate text
	for i = 1, #vals do
		vals[i] = items[vals[i]][2]
	end
	
	local str = table.concat(vals, "\n\n")

	GUI.Val("txted_text", str)
	
end

GUI.name = "Example - Listbox and TextEditor"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 800, 240
GUI.anchor, GUI.corner = "mouse", "C"

--[[	

		Classes and parameters
	
	Button		name, 	z, 	x, 	y, 	w, 	h, caption, func[, ...]
	Listbox		name, 	z, 	x, 	y, 	w, 	h[, list, multi, caption, pad])
	TextEditor	name,	z,	x,	y,	w,	h[, text, caption, pad])
	
]]--


GUI.New("lst_titles", "Listbox",	1,	16,  16,  300, 208, "", true)
GUI.New("btn_go", "Button",			1,	324, 96, 32,  24, "-->", add_text) 
GUI.New("txted_text", "TextEditor",	1,	364, 16,  420, 208, "Select an item\nor two\nor three\nor everything\n\nin the list and click the button!")

local titles = {}
for i = 1, #items do
	titles[i] = items[i][1]
end
GUI.Val("lst_titles", titles)


function GUI.elms.lst_titles:ondoubleclick()

	add_text()
	
end


GUI.Init()
GUI.Main()
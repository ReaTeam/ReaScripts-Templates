--[[

	Lokasenna_GUI Library
	Example user functions
	
	by Lokasenna

]]--


--[[
	Remove an element from the master table. Could be useful for
	dynamically adding/removing elements depending on what the user
	has selected.	
	
	The element name must be given as a string.
]]--
local function remove_elm(elm)

	for key, value in pairs(GUI.elms) do
		if key == elm then GUI.elms[key] = nil end
	end

end



--[[
	How to link the values of two elements together, so that changing
	one causes the other to change as well. In this case, we're linking
	a Knob, "vol_knb", and a Textbox, "text" (after pressing Return).
]]--

local last_focus = false
function knob_from_txt()
	
	local focus = GUI.elms.text.focus
	local knb = GUI.Val("vol_knb")
	
	
	if last_focus == true and focus == false and GUI.char == 13 then
		
		GUI.Val("vol_knb", tonumber(GUI.Val("text")))
		
	elseif last_knb ~= knb then
	
		GUI.Val("text", knb)
		
	end
	
	last_knb = knb
	last_focus = focus
	
end




--[[
	Setting and returning new values for the steps of a knob.	

	Note that the table needs to start at index 0 because that's what
	the	Knob's internal code starts at. Starting at 1 is for weirdos.
]]--

-- Place in whatever user function you've got going on.
local value = GUI.elms.note_len.output[GUI.Val("note_len")]

-- Must be placed after GUI.elms is declared.
GUI.elms.note_len.output = {
	[0] = "1/64",
	"1/32",
	"1/16",
	"1/8",
	"1/4",
	"1/2"
}




--[[
	Adding your own text to a Range slider's values	
]]--

local last_a, last_b = 0, 0
function range_labels()
	
	local a, b = GUI.Val("range_sldr")
	
	if a ~= last_a or b ~= last_b then
		
		GUI.elms.range_sldr.output_a = "A = "..a.."%"
		GUI.elms.range_sldr.output_b = "B = "..b.."%"
	
	end
	
	last_a, last_b = a, b
	
end




--[[
	Getting the text of the selected option from a Radio box,
	and spitting it out into a Textbox.
]]--

function radio_text()
	
	local val = GUI.Val("options")
	local str = GUI.elms.options.optarray[val]
	
	GUI.Val("text", str)
	
end




--[[
	Getting the values of a Checklist's options
]]--
function check_values()
	
	local opts = GUI.Val("list")
	local str = ""
	
	for key, val in pairs(opts) do
		
		str = str.." "..tostring(val)
		
	end
	
end
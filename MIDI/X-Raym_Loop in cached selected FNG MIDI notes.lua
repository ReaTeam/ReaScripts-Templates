--[[
 * ReaScript Name: 
 * Author: 
 * Author URI: 
 * Licence: GPL v3
 * REAPER: 5.0 pre 15
 * Extensions: None
 * Version: 1.0
 * Extension: SWS 2.8.7
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-07-21)
	+ Initial Release
--]]

--[[
Avaible FNG Notes Properties:
	-- SELECTED
	-- LENGTH
	-- POSITION
	-- CHANNEL
	-- PITCH
	-- MUTED
	-- VELOCITY
]]--

local reaper = reaper

function Main( take )
  		
	retval, notes, ccs, sysex = reaper.MIDI_CountEvts( take )
	
	take_fng = reaper.FNG_AllocMidiTake(take)
	
	-- GET SELECTED NOTES (from 0 index)
	for k = 0, notes - 1 do
	  		
		note_fng = reaper.FNG_GetMidiNote(take_fng, i)
		
		note_fng_sel = reaper.FNG_GetMidiNoteIntProperty(note_fng, "SELECTED")
		
		if note_fng_sel == 1 then
		
			-- ACTION HERE
			reaper.FNG_SetMidiNoteIntProperty(note_fng, "LENGTH", new_length)
		
		end
	  	
	end
	
	reaper.FNG_FreeMidiTake(take_fng)

end

-------------------------------
-- INIT
-------------------------------

take = reaper.MIDIEditor_GetTake( reaper.MIDIEditor_GetActive() )

if take then
	
	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	Main( take ) -- Execute your main function
	
	reaper.Undo_EndBlock("Mute selected note in open MIDI take randomly", 0) -- End of the undo block. Leave it at the bottom of your main function.
	
	reaper.UpdateArrange() -- Update the arrangement (often needed)

end -- ENDIF Take is MIDI

--[[
 * ReaScript Name: Mute selected notes in open MIDI take randomly
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Licence: GPL v3
 * REAPER: 5.0 pre 15
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-07-21)
	+ Initial Release
--]]

local reaper = reaper

function Main( take )
  		
	retval, notes, ccs, sysex = reaper.MIDI_CountEvts( take )
	
	-- GET SELECTED NOTES (from 0 index)
	for k = 0, notes - 1 do
	  		
		local retval, sel, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote( take, k )
		
		if sel then
		
			-- ACTION HERE
			reaper.MIDI_SetNote( take, k, sel, muted, startppq, endppq, chan, pitch, vel )
		
		end
	  	
	end

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

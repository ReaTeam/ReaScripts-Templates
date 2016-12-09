--[[
 * ReaScript Name: 
 * Author: 
 * Author URI: 
 * Licence: GPL v3
 * REAPER: 5.0
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
	for id = 0, ccs - 1 do

		local retval, sel, muted, startppq, chanmsg, chan, msg2, val = reaper.MIDI_GetCC( take, id )
		
		if sel then
		
			-- ACTION HERE
			val = 100 -- 0-127
			
			reaper.MIDI_SetCC( take, id, sel, muted, startppq, chanmsg, chan, msg2, val, false )
		
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
	
	reaper.Undo_EndBlock("", 0) -- End of the undo block. Leave it at the bottom of your main function.
	
	reaper.UpdateArrange() -- Update the arrangement (often needed)

end -- ENDIF Take is MIDI

--[[
 * ReaScript Name: 
 * Description: 
 * Instructions: Run
 * Author: 
 * Author URI: 
 * Repository: 
 * Repository URI: 
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: 
 * Forum Thread URI: 
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-01-29)
	+ Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end

--------------------------------------------------------- END OF UTILITIES


function main()

	-- LOOP TRHOUGH SELECTED TRACKS
	for i = 0, sel_tracks_count - 1  do
		-- GET THE TRACK
		local track = reaper.GetSelectedTrack(0, i) -- Get selected track i
		
		-- Set New Property Value
		reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", 0)
		
		-- Set New Name Value
		local retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "new track name", true)

	end -- ENDLOOP through selected tracks

end


-- INIT

sel_tracks_count = reaper.CountSelectedTracks(0)

if sel_tracks_count > 0 then

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	reaper.PreventUIRefresh(1)

	main() -- Execute your main function

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.PreventUIRefresh(-1)
	
	reaper.Undo_EndBlock("My action", -1) -- End of the undo block. Leave it at the bottom of your main function.
	
end

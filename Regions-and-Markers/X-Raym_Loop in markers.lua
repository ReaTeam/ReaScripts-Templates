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


-- USER CONFIG AREA ---------------------------------------------------------

console = true -- true/false: display debug messages in the console

----------------------------------------------------- END OF USER CONFIG AREA


-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end


-- Main function
function main()

	-- LOOP THROUGH REGIONS
	i=0
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
		if iRetval >= 1 then
			if bIsrgnOut == false then
				-- ACTION ON MARKERS HERE
			end
			i = i+1
		end
	until iRetval == 0
	
end


-- INIT ---------------------------------------------------------------------

-- Here: your conditions to avoid triggering main without reason.

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

main()

reaper.Undo_EndBlock("My action", -1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)

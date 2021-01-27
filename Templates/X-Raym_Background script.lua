--[[
 * ReaScript Name: Background Script
 * About: A template script for running in background REAPER ReaScript, with toolbar button ON/OFF state.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Toolbar button toggle state for script actions?
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=164034
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-08-26)
	+ Initial Release
 --]]
 
 -- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end


-- Main Function (which loop in background)
function main()
  
  reaper.defer( main )
  
end



-- RUN
SetButtonState( 1 )
main()
reaper.atexit( SetButtonState )

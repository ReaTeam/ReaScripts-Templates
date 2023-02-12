--[[
 * ReaScript Name: Background Script
 * About: A template script for running in background REAPER ReaScript, with toolbar button ON/OFF state.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Toolbar button toggle state for script actions?
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=164034
 * REAPER: 6.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-08-26)
  + Initial Release
--]]
 
-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end


-- Main Function (which loop in background)
function Main()
  
  reaper.defer( Main )
  
end



-- RUN
SetButtonState( 1 )
Main()
reaper.atexit( SetButtonState )

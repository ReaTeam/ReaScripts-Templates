--[[
 * ReaScript Name: Continuous push shortcut
 * Author: X-Raym
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-04-10)
  + Initial Release
--]]

-- USER CONFIG AREA --
action_id = 40725 -- Grid: Toggle measure grid
VirtualKeyCode = 0x47 -- G -- https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes

----------------------

-- Globals
toggle_state = reaper.GetToggleCommandState( action_id ) 

-- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end
  
-- Main Function (which loop in background)
function main()

  state = reaper.JS_VKeys_GetState(0)

  if state:byte(VirtualKeyCode) ~= 0 then
    if toggle_state == 0 then
      reaper.ShowConsoleMsg("G key is pressed" .. "\n")
      reaper.Main_OnCommand( action_id, 0 ) -- Toggle grid
      toggle_state = 1
    end
  else
    if toggle_state == 1 then
      reaper.ShowConsoleMsg("G key is released" .. "\n")
      reaper.Main_OnCommand( action_id, 0 ) -- Toggle grid
      toggle_state = 0
    end
  end
  
  reaper.defer( main )
  
end

-- RUN
if not reaper.JS_VKeys_GetState then
  reaper.ShowConsoleMsg('Please Install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\n')
else
  reaper.ClearConsole()
  SetButtonState( 1 )
  main()
  reaper.atexit( SetButtonState )
end

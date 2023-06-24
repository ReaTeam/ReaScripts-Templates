--[[
 * ReaScript Name: ReaImGui Simple Template
 * Author: 
 * Author URI: 
 * Repository: 
 * Licence: GPL v3
 * Version: 1.0
--]]

--[[
 * Changelog
 * v1.0 (2023-02-21)
  + Initial release
--]]

--------------------------------------------------------------------------------
-- USER CONFIG AREA --
--------------------------------------------------------------------------------

console = true -- Display debug messages in the console
reaimgui_force_version = false -- false or string like "0.8.4"

--------------------------------------------------------------------------------
                                                   -- END OF USER CONFIG AREA --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- GLOBALS --
--------------------------------------------------------------------------------

input_title = "XR - Title"

--------------------------------------------------------------------------------
-- DEPENDENCIES --
--------------------------------------------------------------------------------

if not reaper.ImGui_CreateContext then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

if reaimgui_force_version then
  reaimgui_shim_file_path = reaper.GetResourcePath() .. '/Scripts/ReaTeam Extensions/API/imgui.lua'
  if reaper.file_exists( reaimgui_shim_file_path ) then
    dofile( reaimgui_shim_file_path )(reaimgui_force_version)
  end
end

--------------------------------------------------------------------------------
                                                       -- END OF DEPENDENCIES --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- DEBUG --
--------------------------------------------------------------------------------

function Msg( value )
  if console then
    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
  end
end

--------------------------------------------------------------------------------
-- DEFER --
--------------------------------------------------------------------------------

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState()
end

--------------------------------------------------------------------------------
-- OTHER --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- MAIN --
--------------------------------------------------------------------------------

function Main()
  --------------------
  -- YOUR CODE HERE --
  --------------------
end

function Run()
  
  reaper.ImGui_SetNextWindowBgAlpha( ctx, 1 )

  reaper.ImGui_PushFont(ctx, font)
  reaper.ImGui_SetNextWindowSize(ctx, 800, 200, reaper.ImGui_Cond_FirstUseEver())

  if set_dock_id then
    reaper.ImGui_SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end

  local imgui_visible, imgui_open = reaper.ImGui_Begin(ctx, input_title, true, reaper.ImGui_WindowFlags_NoCollapse())

  if imgui_visible then

    imgui_width, imgui_height = reaper.ImGui_GetWindowSize( ctx )

    Main()
    
    --------------------

    reaper.ImGui_End(ctx)
  end
  
  reaper.ImGui_PopFont(ctx)

  if imgui_open and not reaper.ImGui_IsKeyPressed(ctx, reaper.ImGui_Key_Escape()) and not process then
    reaper.defer(Run)
  end

end -- END DEFER

--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------

function Init()
  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = reaper.ImGui_CreateContext(input_title)
  font = reaper.ImGui_CreateFont('sans-serif', 16)
  reaper.ImGui_Attach(ctx, font)

  reaper.defer(Run)
end

if not preset_file_init then
  Init()
end

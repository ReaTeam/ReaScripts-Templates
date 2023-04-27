input_title = "XR - Title"

if not reaper.ImGui_CreateContext then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

reaimgui_shim_file_path = reaper.GetResourcePath() .. '/Scripts/ReaTeam Extensions/API/imgui.lua'
if reaper.file_exists( reaimgui_shim_file_path ) then
  dofile( reaimgui_shim_file_path )('0.8.6')
end

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState()
end

----------------------------------------------------------------------
-- OTHER --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- RUN --
----------------------------------------------------------------------
function Main()
  --------------------
  -- YOUR CODE HERE --
  --------------------
end

function Run()

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

  if imgui_open and not reaper.ImGui_IsKeyPressed(ctx, reaper.ImGui_Key_Escape()) and not process then
    reaper.defer(Run)
  end

end -- END DEFER


----------------------------------------------------------------------
-- RUN --
----------------------------------------------------------------------

function Init()
  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = reaper.ImGui_CreateContext(input_title)

  reaper.defer(Run)
end

Init()

input_title = "XR - Title"

reaimgui_force_version = "0.10.0.5"

imgui_path = reaper.ImGui_GetBuiltinPath and ( reaper.ImGui_GetBuiltinPath() .. '/imgui.lua' )

if not imgui_path then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

local ImGui = dofile(imgui_path) (reaimgui_force_version)

function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState()
end


function Main()

end

function Run()

  if set_dock_id then
    ImGui.SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end

  local imgui_visible, imgui_open = ImGui.Begin(ctx, input_title, true, ImGui.WindowFlags_NoCollapse)

  if imgui_visible then

    imgui_width, imgui_height = ImGui.GetWindowSize( ctx )

    Main()

    ImGui.End(ctx)
  end

  if imgui_open and not ImGui.IsKeyPressed(ctx, ImGui.Key_Escape) then
    reaper.defer(Run)
  end

end -- END DEFER

function Init()
  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = ImGui.CreateContext(input_title)

  reaper.defer(Run)
end

Init()

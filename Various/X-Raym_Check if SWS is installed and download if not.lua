function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end

function Open_URL(url)
  if not OS then local OS = reaper.GetOS() end
  if OS=="OSX32" or OS=="OSX64" then
    os.execute("open ".. url)
   else
    os.execute("start ".. url)
  end
end

function CheckSWS()
  local SWS_installed
  if not reaper.BR_SetMediaTrackLayouts then
    local retval = reaper.ShowMessageBox("SWS extension is required by this script.\nHowever, it doesn't seem to be present for this REAPER installation.\n\nDo you want to download it now ?", "Warning", 1)
    if retval == 1 then
      Open_URL("http://www.sws-extension.org/download/pre-release/")
    end
  else
    SWS_installed = true
  end
  return SWS_installed
end

if not CheckSWS() then return end -- Abord the script loading.

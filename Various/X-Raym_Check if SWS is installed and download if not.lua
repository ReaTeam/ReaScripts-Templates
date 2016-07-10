function CheckSWS()
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
  local reaperkey = {}
  for k, v in pairs(reaper) do
    reaperkey[k] = 0
  end
  
  if reaperkey["BR_SetMediaTracksLayout"] then 
    return true
  else
    local retval = reaper.ShowMessageBox("SWS extension is required by this script.\nHowever, it doesn't seem to be present for this REAPER installation.\n\nDo you want to download it now ?", "Warning", 1)
    if retval == 1 then
      Open_URL("http://www.sws-extension.org/download/pre-release/")
    end
  end
end

sws = CheckSWS()

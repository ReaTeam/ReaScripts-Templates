-- For SWS v2.9.9.0
reaper.ClearConsole()

function msg(m)
  return reaper.ShowConsoleMsg(tostring(m) .. "\n")
end

-- set subs
count_markers_and_regions, count_regions = reaper.CountProjectMarkers(0)
for i = 0, count_markers_and_regions - 1 do
  local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut =  reaper.EnumProjectMarkers( i )
  
  if isrgnOut == true then 
    mkrRgnSubIn = "new Subtitle text for region " .. markrgnindexnumberOut
  else
    mkrRgnSubIn = "new Subtitle text for marker " .. markrgnindexnumberOut
  end
  
  regionSubIsSet = reaper.NF_SetSWSMarkerRegionSub(mkrRgnSubIn, i)
  i = i + 1
end
reaper.NF_UpdateSWSMarkerRegionSubWindow() -- optional

-- get subs
count_markers_and_regions, count_regions = reaper.CountProjectMarkers(0)
for i = 0, count_markers_and_regions - 1 do
  local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut =  reaper.EnumProjectMarkers( i )
  markerIdx, regionIdx = reaper.GetLastMarkerAndCurRegion( 0, posOut )
  local mkrRgnSubOut = reaper.NF_GetSWSMarkerRegionSub(i)
  msg("i = " .. i)
  msg("retval = " .. retval)
  msg("is_region = " .. tostring(isrgnOut))
  msg("markrgnindexnumberOut = " .. markrgnindexnumberOut)
  msg("NOTES = " .. mkrRgnSubOut)
  msg("")
  i = i + 1
end
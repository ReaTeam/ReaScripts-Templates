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
    fastStringIn = reaper.SNM_CreateFastString("new Subtitle text for region " .. markrgnindexnumberOut)
  else
    fastStringIn = reaper.SNM_CreateFastString("new Subtitle text for marker " .. markrgnindexnumberOut)
  end
  
  regionSubIsSet = reaper.NF_SetSWSMarkerRegionSub(fastStringIn,i)
  reaper.SNM_DeleteFastString(fastStringIn)
  i = i + 1
end

reaper.NF_UpdateSWSMarkerRegionSubWindow()

-- get subs
count_markers_and_regions, count_regions = reaper.CountProjectMarkers(0)
for i = 0, count_markers_and_regions - 1 do
  local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut =  reaper.EnumProjectMarkers( i )
  markerIdx, regionIdx = reaper.GetLastMarkerAndCurRegion( 0, posOut )
  local fastStringOut = reaper.SNM_CreateFastString("")
  regionSub = reaper.NF_GetSWSMarkerRegionSub(fastStringOut, i)
  msg("i = " .. i)
  msg("retval = " .. retval)
  msg("is_region = " .. tostring(isrgnOut))
  msg("markrgnindexnumberOut = " .. markrgnindexnumberOut)
  msg("NOTES = " .. regionSub)
  msg("")
  reaper.SNM_DeleteFastString(fastStringOut)
  i = i + 1
end

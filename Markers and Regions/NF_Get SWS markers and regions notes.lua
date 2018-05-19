-- For SWS v2.9.9.0
reaper.ClearConsole()

function msg(m)
  return reaper.ShowConsoleMsg(tostring(m) .. "\n")
end

-- set subs
fastStringIn = reaper.SNM_CreateFastString("")
count_markers_and_regions, count_regions = reaper.CountProjectMarkers(0)
for i = 0, count_markers_and_regions - 1 do
  local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut =  reaper.EnumProjectMarkers( i )
  
  if isrgnOut == true then 
    reaper.SNM_SetFastString(fastStringIn, "new Subtitle text for region " .. markrgnindexnumberOut)
  else
    reaper.SNM_SetFastString(fastStringIn, "new Subtitle text for marker " .. markrgnindexnumberOut)
  end
  
  regionSubIsSet = reaper.NF_SetSWSMarkerRegionSub(fastStringIn, i)
  i = i + 1
end
reaper.SNM_DeleteFastString(fastStringIn)
reaper.NF_UpdateSWSMarkerRegionSubWindow() -- optional

-- get subs
fastStringOut = reaper.SNM_CreateFastString("")
count_markers_and_regions, count_regions = reaper.CountProjectMarkers(0)
for i = 0, count_markers_and_regions - 1 do
  local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut =  reaper.EnumProjectMarkers( i )
  markerIdx, regionIdx = reaper.GetLastMarkerAndCurRegion( 0, posOut )
  regionSub = reaper.NF_GetSWSMarkerRegionSub(fastStringOut, i)
  msg("i = " .. i)
  msg("retval = " .. retval)
  msg("is_region = " .. tostring(isrgnOut))
  msg("markrgnindexnumberOut = " .. markrgnindexnumberOut)
  msg("NOTES = " .. regionSub)
  msg("")
  i = i + 1
end
reaper.SNM_DeleteFastString(fastStringOut)
function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

function GetTrackChildIdAndCount(id)
  local id = id -1  
  local i = 0
  local level = 0
  repeat
    local track = reaper.GetTrack(0, id+i)
    if track ~= nil then
      local folder = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
      level = level + folder
      i = i+1
    end
  until level <= 0 or track == nil
  
  local last_id = id + i
  local child_number = i-1
  return last_id, child_number

end



ref = reaper.GetSelectedTrack(0,0)
ref_id = reaper.GetMediaTrackInfo_Value(ref, "IP_TRACKNUMBER")
aaaaa, aaaaaa = GetTrackChildIdAndCount(ref_id)


for i = 0, reaper.CountTracks(0) -1 do
  track= reaper.GetTrack(0, i)
  folder_depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
  retval, string = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "Track "..tostring(folder_depth), true)
end

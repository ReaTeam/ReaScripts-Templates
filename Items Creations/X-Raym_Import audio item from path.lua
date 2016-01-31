function ImportAudioItemFromPath(path, track, position, length)
  
  local retval
  local created
  
  local item = reaper.AddMediaItemToTrack(track)
  
  reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)
  
  local take = reaper.AddTakeToMediaItem(item)
  
  local pcm = reaper.PCM_Source_CreateFromFile(path)

  if pcm ~= nil then
    created = reaper.BR_SetTakeSourceFromFile(take, path, false)
    reaper.UpdateItemInProject(item)
    retval = item
  else
    reaper.DeleteTrackMediaItem(track, item)
    retval = nil
  end
  
  return retval

end

track = reaper.GetTrack(0,0)

retval, file_path = reaper.GetUserFileNameForRead("", "Import from file", "")

item = ImportAudioItemFromPath(file_path, track, 0, 2)

if item ~= nil then

  reaper.Main_OnCommand(40048, 0) -- rebuild all peak
  reaper.UpdateArrange()
  
end

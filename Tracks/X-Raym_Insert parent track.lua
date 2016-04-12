
function InsertParentTrack(track_id, end_track_id)
  
  -- Store actual folders state
  last_track = reaper.GetTrack(0, end_track_id - 1)
  last_depth = reaper.GetMediaTrackInfo_Value(last_track, "I_FOLDERDEPTH")
  next_track = reaper.GetTrack(0, end_track_id)
  next_depth = reaper.GetMediaTrackInfo_Value(next_track, "I_FOLDERDEPTH")
  
  -- Insert a new track
  reaper.InsertTrackAtIndex(track_id-1, true) -- 0 based
  parent_track = reaper.GetTrack(0, track_id-1)
  reaper.SetMediaTrackInfo_Value(parent_track, "I_FOLDERDEPTH", 1)
  
  last_track = reaper.GetTrack(0, end_track_id) -- -1 for 0 based, +1 because new track
  -- last track has childs or not
  if last_depth == 1 then -- If last track in seletcion is a folder, then folder it
    reaper.SetMediaTrackInfo_Value(last_track, "I_FOLDERDEPTH", 1)
  else
    reaper.SetMediaTrackInfo_Value(last_track, "I_FOLDERDEPTH", last_depth-2)
  end
  
  -- Maybe next tracj should be the next track which is not parent of the last trac
  next_track = reaper.GetTrack(0, end_track_id+1)
  if next_track ~= nil then
    reaper.SetMediaTrackInfo_Value(next_track, "I_FOLDERDEPTH", next_depth-1)
  end  

end


InsertParentTrack(1, 3)

reaper.TrackList_AdjustWindows(true)

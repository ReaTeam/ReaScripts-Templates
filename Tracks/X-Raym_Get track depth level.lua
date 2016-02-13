function GetTrackFolderLevel(track) -- This is what reaper.GetTrackDepth already do !!!!!!!!
  local idx = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
  local level = 0
  if idx > 1 then -- if not the first track (first track will always be 0)
    for z = 1, idx -1 do
      local track = reaper.GetTrack(0, z-1)
      local depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
      level = level + depth
    end
  end
  return level
end

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

----------------------------------------
-- RENAME (for debugging)
function RenameTracksWithFolderDepth()
  for i = 0, reaper.CountTracks(0) - 1 do
    local track = reaper.GetTrack(0,i)
    local depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    local retval, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", depth,true)
  end
end


function RenameTracksWithLevel()
  for i = 0, reaper.CountTracks(0) - 1 do
    local track = reaper.GetTrack(0,i)
    local depth = GetTrackFolderLevel(track)
    local retval, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", depth,true)
  end
end


----------------------------------------
-- MAIN


-- Insert Track at Level 0 after last track
function main()
  count_tracks = reaper.CountTracks(0)
  
  reaper.InsertTrackAtIndex(count_tracks, false)
  
  track = reaper.GetTrack(0,count_tracks)
  --level_new = GetTrackFolderLevel(track)
  pre_track = reaper.GetTrack(0,count_tracks-1)
  level = GetTrackFolderLevel(pre_track)
  if level > 0 then
    reaper.SetMediaTrackInfo_Value(pre_track, "I_FOLDERDEPTH", -1 - level)
  end

end

----------------------------------------
-- INIT

console = true

reaper.ClearConsole()

reaper.Undo_BeginBlock()

main()

-- Comment/Uncomment see to see what is the difference between Folder Depth and Level Depth
--RenameTracksWithFolderDepth()
RenameTracksWithLevel()

reaper.TrackList_AdjustWindows(true)
reaper.Undo_EndBlock("Action", -1)

-- Debug
--level_sel = GetTrackFolderLevel(reaper.GetSelectedTrack(0,0))

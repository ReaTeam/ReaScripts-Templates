reaper.Undo_BeginBlock()

FX = "ReaComp"

TrackIdx = 0
TrackCount = reaper.CountSelectedTracks(0)
while TrackIdx < TrackCount do
 track = reaper.GetSelectedTrack(0, TrackIdx)
 reaper.TrackFX_AddByName( track, FX, 0, -1 )
 TrackIdx =TrackIdx+1
end

reaper.Undo_EndBlock("Add new track FX instance",-1)

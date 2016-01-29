-- You can change "value" parameter to negative value

value = 0.01 

script_title = "Add value to last touched FX parameter"
reaper.Undo_BeginBlock()
retval, trackid, fxid, paramid = reaper.GetLastTouchedFX()
if retval ~= nil then
  track = reaper.GetTrack(0, trackid-1)
  if track ~= nil then
    value0 = reaper.TrackFX_GetParamNormalized(track, fxid, paramid)
    newval = value0 + value
    if newval > 1 then newval = 1 end
    if newval < 0 then newval = 0 end
    reaper.TrackFX_SetParamNormalized(track, fxid, paramid, newval) 
  end  
end
reaper.Undo_EndBlock(script_title, 1)

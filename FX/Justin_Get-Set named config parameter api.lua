-- http://forum.cockos.com/showpost.php?p=1817782&postcount=5

ok, fn = reaper.TrackFX_GetNamedConfigParm(track,fx, "FILE0") -- get first sample filename
ok, fn2 = reaper.TrackFX_GetNamedConfigParm(track,fx, "FILE1") -- get second sample filename


ok = reaper.TrackFX_SetNamedConfigParm(track,fx, "FILE0", fn) -- set first sample filename
ok = reaper.TrackFX_SetNamedConfigParm(track,fx, "FILE1", fn2) -- set second sample filename -- note that FILE0 must exist before you can set FILE1, etc.

ok = reaper.TrackFX_SetNamedConfigParm(track,fx, "-FILE0", "") -- remove first sample (second sample becomes first sample)

ok = reaper.TrackFX_SetNamedConfigParm(track,fx, "+FILE0", fn) -- insert sample (old FILE0 becomes FILE1)

ok = reaper.TrackFX_SetNamedConfigParm(track,fx, "-FILE*", "") -- remove all samples

-- Finally, when the script is finished updating the samples, it should call (this will trigger actually loading the samples from disk, adding an undo point, etc):
reaper.TrackFX_SetNamedConfigParm(track,fx, "DONE","")


--[[
REAPER v5.40pre13
+ ReaVerb: support TrackFX_SetNamedConfigParm et al w/ ITEMx, DONE
+ Reasamplomatic: support TrackFX_SetNamedConfigParm with MODE, RSMODE
--]]

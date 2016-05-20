-- some nil protections could be added
env = reaper.GetSelectedTrackEnvelope(0)

br_env = reaper.BR_EnvAlloc(env, false)

track = reaper.BR_EnvGetParentTrack(br_env)

reaper.BR_EnvFree(env, false)

retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

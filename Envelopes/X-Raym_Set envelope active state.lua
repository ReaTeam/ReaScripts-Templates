function SetEnvActiveState(env, state)
  local BR_Env = reaper.BR_EnvAlloc(env, false)
  local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)
  reaper.BR_EnvSetProperties(br_env, state, visible_out, armed_out, inLane, laneHeight, defaultShape, faderScaling)
  reaper.BR_EnvFree(BR_Env, true)
end

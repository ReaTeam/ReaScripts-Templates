envPtr = reaper.GetSelectedEnvelope(0)
if envPtr ~= nil then
  envelope = reaper.BR_EnvAlloc(envPtr, true)
  
  for i = 0, reaper.BR_EnvCountPoints(envelope) - 1 do
    valid, _,_,_, selected = reaper.BR_EnvGetPoint(envelope, i, 0, 0, 0, 0, 0)
    if not valid then
      break
    elseif selected then
      reaper.BR_EnvDeletePoint(envelope, i)
      i = i -1
    end
  end
  reaper.BR_EnvFree(envelope, true)
end

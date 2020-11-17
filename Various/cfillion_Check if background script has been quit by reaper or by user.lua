https://forum.cockos.com/showpost.php?p=2225040&postcount=9

reaper.atexit(function()
  if reaper.EnumProjects(0) then -- check whether SWS functions are still available (REAPER is not exiting)
    reaper.SNM_SetDoubleConfigVar("envtranstime", origTransitionTime)
  end
end)

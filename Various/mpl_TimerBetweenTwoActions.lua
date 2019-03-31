-- Timer template --
---------------------------------------------------
time = 10 -- time in seconds you need for pause
action_id_1 = 00000 -- insert here first action ID
action_id_2 = 00000 -- insert here second action ID
---------------------------------------------------




function timer() 
 time2 = reaper.time_precise()
 time_con = true
 if time_con == true then
  if time2 - time1 < time then   
   time_con = true
   reaper.defer(timer)
   else
   time_con = false   
  end
 end  
end

function sec_fn ()
reaper.Main_OnCommand(action_id_2, 0)
reaper.UpdateArrange()
end



-- PERFORM:
reaper.Main_OnCommand(action_id_1, 0) reaper.UpdateArrange()  -- execute 1st defined action

time1 = reaper.time_precise() timer() -- wait for defined time

reaper.atexit(sec_fn) -- execute 2nd defined action, stop running script

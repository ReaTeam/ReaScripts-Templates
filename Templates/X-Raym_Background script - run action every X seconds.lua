time = 1 -- time in seconds before each action
time1 = reaper.time_precise()

--
function Main()  
 time2 = reaper.time_precise() 
 if time2 - time1 > time then 
  
  time1 =  reaper.time_precise() -- reset timer

  reaper.ShowConsoleMsg("Your action there\n")

 end   

 reaper.defer(Main) 
end

-- Run
Main()  

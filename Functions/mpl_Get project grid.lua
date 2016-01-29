function GetProjectGrid()
  local grid_time,beats,measures,cml,grid_div
  grid_time = reaper.BR_GetNextGridDivision(0)
  beats, measures, cml = reaper.TimeMap2_timeToBeats(0, grid_time)
  if measures == 0 then
    grid_div = math.ceil(cml/beats)
    if grid_div % 3 == 0 then grid_string = "1/"..math.floor(grid_div/3*2).."T" 
      else
       grid_string = "1/"..math.floor(grid_div)
    end
   else
    grid_string = measures
  end 
  return grid_string
end

grid_str = GetProjectGrid()

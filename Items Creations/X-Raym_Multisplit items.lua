-- TO DO:
-- prevent bad value insertion
-- sort table
function MultiSplitMediaItem(item, times)

  local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local item_end = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + item_pos
  
  -- create array then reserve some space in array
  local items = {}
  
  -- add 'item' to 'items' array
  table.insert(items, item)
  
  -- for each time in times array do...
  for i, time in ipairs(times) do
  
    if time > item_end then break end
    
    if time > item_pos and time < item_end then
  
      -- store item so we can split it next time around
      item = reaper.SplitMediaItem(item, time)
      
      -- add resulting item to array
      table.insert(items, item)
      
    end

  end

  -- return 'items' array
  return items

end

function main()
  for i = 0, count_selected_items - 1 do

    item = reaper.GetSelectedMediaItem(0, i)
    item_free_y = reaper.GetMediaItemInfo_Value(item, "F_FREEMODE_Y")
    item_free_h = reaper.GetMediaItemInfo_Value(item, "F_FREEMODE_H")
  
    Msg(i)
    Msg(item_free_y)
    Msg(item_free_h)
    
    item_free_h = reaper.SetMediaItemInfo_Value(item, "F_FREEMODE_H", 1/count_selected_items)
    item_free_y = reaper.SetMediaItemInfo_Value(item, "F_FREEMODE_Y", i * (1/count_selected_items))

  end
end

function Msg(value)
  reaper.ShowConsoleMsg(tostring(value).."\n")
end

count_selected_items = reaper.CountSelectedMediaItems(0)
if count_selected_items > 0 then
  main()
end

-- Create a Text Item.
-- Return the item if success. Else, return nil.
function CreateTextItem(track, position, length, text, color)
    
	local item = reaper.AddMediaItemToTrack(track)
  
	reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
	reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)
  
	if text then
		reaper.ULT_SetMediaItemNote(item, text)
	end
  
	if color then
		reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
	end
  
	return item

end

-- Create a text Items with "Text" as notes on first track.
track = reaper.GetTrack(0, 0)
CreateTextItem(track, 0, 1, "Text", 0)

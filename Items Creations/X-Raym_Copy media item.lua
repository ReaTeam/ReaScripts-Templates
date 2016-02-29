-- Copy Media Item to Position and Track
-- Return the item if success. Else, return nil.
function CopyMediaItem(item, track, position)
    
	local new_item = reaper.AddMediaItemToTrack(track)
	
	local retval, item_chunk =  reaper.GetItemStateChunk(item, '')
	
	reaper.SetItemStateChunk(new_item, item_chunk)
  
	reaper.SetMediaItemInfo_Value(new_item, "D_POSITION", position)
	
	reaper.UpdateItemInProject(new_item)

	return new_item

end

-- Copy first selected item on first track at position 10
sel_item = reaper.GetSelectedMediaItem(0,0)
if sel_item then
	track = reaper.GetTrack(0, 0)
	new_item = CopyMediaItem(sel_item, track, 10)
	reaper.UpdateArrange()
end

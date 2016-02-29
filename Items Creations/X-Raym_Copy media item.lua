-- This is an experimentation.
-- Problem is item and take GUID that need to be modified.
-- Not that handy as tehre is no "set take GUID" or "SetTakeXML" function

-- Create a Text Item.
-- Return the item if success. Else, return nil.
function CopyMediaItem(item, track, position)
    
	local new_item = reaper.AddMediaItemToTrack(track)
	local new_item_guid = reaper.BR_GetMediaItemGUID(new_item)
	Msg(new_item_guid)
	local retval, item_chunk =  reaper.GetItemStateChunk(item, '')
	new_item_chunk = item_chunk:gsub('IGUID ({.+})', 'IGUID ' .. new_item_guid )
	
	Msg(item_chunk)
	Msg(new_item_chunk)
		
	reaper.SetItemStateChunk(new_item, new_item_chunk)
	
	reaper.SetMediaItemInfo_Value(new_item, "D_POSITION", position)
	
	reaper.UpdateItemInProject(new_item)
	
	return new_item

end


console = true
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end


-- Copy first selected item on first track
sel_item = reaper.GetSelectedMediaItem(0,0)
if sel_item then
	track = reaper.GetTrack(0, 0)
	new_item = CopyMediaItem(sel_item, track, 10)
	reaper.UpdateArrange()
	item_guid = reaper.BR_GetMediaItemGUID(sel_item)
	new_item_guid = reaper.BR_GetMediaItemGUID(new_item)
end
    

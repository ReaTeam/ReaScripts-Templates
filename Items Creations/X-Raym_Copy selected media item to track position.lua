-- Designed for 1 items but could be moded for more.

-- Need to save and Restore View before and after.

-- Copy selected media items
function CopySelectedMediaItems(track, pos)

	local cursor_pos = reaper.GetCursorPosition()

	reaper.SetOnlyTrackSelected(track)

	reaper.Main_OnCommand(40914, 0) -- Select first track as last touched

	reaper.SetEditCurPos(pos, false, false)

	reaper.Main_OnCommand(40698, 0) -- Copy Items

	reaper.Main_OnCommand(40058, 0) -- Paste Items

	new_item = reaper.GetSelectedMediaItem(0, 0) -- Get First Selected Item

	reaper.SetEditCurPos(cursor_pos, false, false)

	return new_item

end

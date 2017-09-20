-- TO DO:
-- prevent bad value insertion
-- sort table
function MultiSplitMediaItem(item, times)
	
	-- create array then reserve some space in array
	local items = {}
	
	-- add 'item' to 'items' array
	table.insert(items, item)
	
	-- for each time in times array do...
	for i, time in ipairs(times) do
		
		-- store item so we can split it next time around
		item = SplitMediaItem(item, time)
		
		-- add resulting item to array
		table.insert(items, item)

	end

	-- return 'items' array
	return items

end

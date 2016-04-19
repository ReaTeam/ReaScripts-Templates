-- Count the number of times a value occurs in a table 
function table_count(tt, item)
	local count
	count = 0
	for ii,xx in pairs(tt) do
		if item == xx then count = count + 1 end
	end
	return count
end

-- Remove duplicates from a table array
function table_unique(tt)
	local newtable
	newtable = {}
	for ii,xx in ipairs(tt) do
		if(table_count(newtable, xx) == 0) then
			newtable[#newtable+1] = xx
		end
	end
	return newtable
end

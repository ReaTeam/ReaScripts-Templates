-- Count the number of times a value occurs in a table
function CountOccurencesTable(tt, item)
  local count
  count = 0
  for ii,xx in pairs(tt) do
    if item == xx then count = count + 1 end
  end
  return count
end -- CountOccurencesTable()



-- Remove duplicates from a table array
function RemoveTableDuplicates(tt)
  local newtable
  newtable = {}
  for ii,xx in ipairs(tt) do
    if(CountOccurencesTable(newtable, xx) == 0) then
      newtable[#newtable+1] = xx
    end
  end
  return newtable
end -- RemoveTableDuplicates()


-- Get the value with the max occurence in a table
function GetTableMaxOccurenceValue(table)
  max_value = nil
  table_unique = RemoveTableDuplicates(table)

  max_occurences = 0
  for z = 1, #table_unique do
    occurences = CountOccurencesTable(table, table_unique[z])
    if occurences > max_occurences then
      max_occurences = occurences
      max_value = table_unique[z]
    end
  end

  return max_value

end --GetTableMaxOccurenceValue()

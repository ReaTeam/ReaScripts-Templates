name_array = {}
csv_list = "Aaron, Abel, Abe"
i = 1
for name in string.gmatch(csv_list, '([^,]+)') do
  -- do stuff here
  name_array[i] = name -- collect names to "name_array"
  i = i + 1
end

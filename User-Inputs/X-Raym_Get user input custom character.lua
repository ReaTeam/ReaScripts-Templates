separator = "\n"

retval, retvals_csv = reaper.GetUserInputs("Title", 2, "CSV1, CSV2,separator=" .. separator, '')

if retval then
  t = {}
  i = 0
  for line in retvals_csv:gmatch("[^" .. separator .. "]*") do
      i = i + 1
      t[i] = line
  end
end

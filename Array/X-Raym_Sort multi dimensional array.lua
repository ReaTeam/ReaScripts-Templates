-- Sort multi dimensionnal array
-- Can also be used to sort an array against another (if they are collapse into one table) -- not detailed here.

strings_total = 9 -- number of strings. Max is 16 ( for 16 channels ), min is 3 (simpler to design the neck)

-- Prepare Strings Table
strings = {} -- leave it
for i = 1, strings_total do
	strings[i] = {}
end

strings[1].colors = "Red"
strings[1].note = 40 -- E -- 6 strings guitar
strings[2].colors = "Yellow"
strings[2].note = 45 -- A
strings[3].colors = "Green"
strings[3].note = 50 -- D
strings[4].colors = "Blue"
strings[4].note = 55 -- G
strings[5].colors = "Purple"
strings[5].note = 59 -- B
strings[6].colors = "Fuchsia"
strings[6].note = 64 -- E
strings[7].colors = "Orange"
strings[7].note = 35 -- B -- 7 strings guitar
strings[8].colors = "Olive"
strings[8].note = 30 -- F# -- 8 trings guitar
strings[9].colors = "Aqua"
strings[9].note = 25 -- C# -- 9 strings guitar

table.sort(strings, function( a,b )
  if (a.note < b.note) then
    -- primary sort on position -> a before b
    return true
  elseif (a.note > b.note) then
    -- primary sort on position -> b before a
    return false
  else
    -- primary sort tied, resolve w secondary sort on rank
    return a.color < b.color
  end
end)

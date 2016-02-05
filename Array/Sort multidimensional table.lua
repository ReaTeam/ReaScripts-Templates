-- SORT TABLE
-- thanks to https://forums.coronalabs.com/topic/37595-nested-sorting-on-multi-dimensional-array/
table.sort(sel_items, function( a,b )
if (a.note < b.note) then
-- primary sort on position -> a before b
return true
elseif (a.note > b.note) then
-- primary sort on position -> b before a
return false
else
-- primary sort tied, resolve w secondary sort on rank
return a.pos < b.pos
end
end)

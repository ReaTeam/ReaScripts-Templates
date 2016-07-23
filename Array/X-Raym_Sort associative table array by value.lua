-- Sort associative array/table based on their value
-- based on http://stackoverflow.com/questions/15706270/sort-a-table-in-lua
-- Michal Kottman

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end

end

chord = {}
chord[1] = 10
chord[2] = 15
chord[5] = 14

for key, value in pairs(chord) do
	print(key .. " = " .. value)
end

print("----")

for key, value in spairs(chord, function(t,a,b) return t[b] > t[a] end) do -- Sort by frowing order. Invert > for Descending order.
	print(key .. " = " .. value)
end

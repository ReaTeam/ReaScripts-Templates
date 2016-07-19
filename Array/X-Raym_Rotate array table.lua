-- Inspiration: http://stackoverflow.com/questions/22695348/lua-shift-element-left-and-right-in-2d-array

-- Core Function
function RotateTable( array, shift ) -- Works for array with consecutive entries
    shift = shift or 1 -- make second arg optional, defaults to 1
    
    if shift > 0 then
	    for i = 1, math.abs(shift) do
	        table.insert( array, 1, table.remove( array, #array ) )
	    end
	else
		for i = 1, math.abs(shift) do
	        --table.insert( array, 1, table.remove( array, #array ) )
	        table.insert( array, #array, table.remove( array, 1 ) )
	    end	
	end

end

-- Debug
function printTable(tb)
	local string_out = ""
	for i, v in ipairs(tb) do
		string_out = string_out .. v
	end
	print(string_out)
end

testTable = {6,7,8,9}

printTable(testTable)

-- Rotate Right
RotateTable(testTable, -2)
printTable(testTable)

-- Rotate Left
RotateTable(testTable, 2)
printTable(testTable)

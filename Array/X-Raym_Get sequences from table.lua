function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

function GetSequencesFromTable(table)
	
	out = {}
	
	j=1
	out[j] = {}
	out[j].minimum = table[1]
	
	for i = 2, #table do
	
		if table[i] - table[i-1] ~= 1 or i==#table then
			out[j].maximum = table[i-1]
			if i==#table then
				out[j].maximum = table[i]
			else
			  j=j+1
			  out[j] = {}
			  out[j].minimum = table[i]
			 end        
		end
	
	end
	
	return out

end
reaper.ClearConsole()
list = {1,2,3,5,6,8,9,10}
GetSequencesFromTable(list)

--[[
output = {
1 = 1,3
2 = 5,6
3 = 8,9
}
]]

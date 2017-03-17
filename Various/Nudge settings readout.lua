--[[
  Displays the current Nudge settings (as stored in REAPER.ini),
  updated every 0.1 seconds.
  
  Most of the settings are stored in a single binary number, so
  'nudge=' is also displayed in binary form.
]]--


local ini_path = reaper.get_ini_file()

--retval, stringOut reaper.BR_Win32_GetPrivateProfileString( sectionName, keyName, defaultString, filePath )

local vals = {"nudge_vis", "nudge", "nudgecopies", "nudgeamt"}

function reverse(t)
  local nt = {} -- new table
  local size = #t + 1
  for k,v in ipairs(t) do
    nt[size - k] = v
  end
  return nt
end

function tobits(num)
    local t={}
    while num>0 do
        rest=math.floor(num%2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
	for i = #t+1, 16 do
		t[i] = 0
	end
    t = reverse(t)	
    return table.concat(t)
end


local function print_vals()
	
	local rets = {}
	local ret, str

	for i = 1, #vals do
		
		ret, str = reaper.BR_Win32_GetPrivateProfileString("reaper", vals[i], "-n/a", ini_path)	
		
		gfx.x, gfx.y = 20, (i * 10)
		gfx.drawstr(vals[i])
		gfx.x = 128
		if vals[i] ~= "nudge" then
			gfx.drawstr(tostring(str))
		else
			str = tonumber(str)
			gfx.drawstr( str )
			gfx.x = 192
			gfx.drawstr( tobits( str ) )
		end
			
		
	end

end


gfx.init("Nudge settings readout", 352, 64, 0, 200, 200)


local t = reaper.time_precise()

local function Main()
	
	local char = gfx.getchar()
	if char == -1 or char == 27 then return 0 end
	
	local cur_t = reaper.time_precise()
	if cur_t - t > 0.1 then
		t = cur_t
		print_vals()
		gfx.update()
	end

	reaper.defer(Main)
	
end

Main()

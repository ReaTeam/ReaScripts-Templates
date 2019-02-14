-- ===============================================
-- From LuaBit v0.4

local function check_int(n)
 -- checking not float
 if(n - math.floor(n) > 0) then
  Msg("trying to use bitwise operation on non-integer!")
 end
end

local function to_bits(n)
 check_int(n)
 if(n < 0) then
  -- negative
  return to_bits(bit.bnot(math.abs(n)) + 1)
 end
 -- to bits table
 local tbl = {}
 local cnt = 1
 while (n > 0) do
  local last = n %2
  if(last == 1) then
   tbl[cnt] = 1
  else
   tbl[cnt] = 0
  end
  n = (n-last)/2
  cnt = cnt + 1
 end

 return tbl
end
-- ===============================================

-- Update a table based on Bitwise operation
function to_bits_table( number, array )

  local temp_array = to_bits( number )
  
  for i, v in ipairs (array) do
    if temp_array[i] then
      array[i] = temp_array[i]
    else
      array[i] = 0
    end
  end
  
  return array

end

function Main()

  time = os.clock()
  
  joystick_button_mask = reaper.joystick_getbuttonmask( joystick_device )
  
  -- Return a table, each entry is a button, with bolean value to see if it pressed
  joystick_buttons_pressed = to_bits_table( joystick_button_mask, joystick_buttons_pressed )
  
  joystick_pov = reaper.joystick_getpov( joystick_device, 0 )
  
  joystick_x1_axis = reaper.joystick_getaxis( joystick_device, 0 )
  joystick_y1_axis = reaper.joystick_getaxis( joystick_device, 1 )
  joystick_x2_axis = reaper.joystick_getaxis( joystick_device, 3 )
  joystick_y2_axis = reaper.joystick_getaxis( joystick_device, 4 )
  reaper.joystick_update( joystick_device )
  
  reaper.defer( Main )
  
end

-- Create Joystick
index = 0
joystick_guid, joystick_name = reaper.joystick_enum( index )
joystick_device = reaper.joystick_create( joystick_guid )
joystick_buttons, joystick_axes, joystick_povs = reaper.joystick_getinfo( joystick_device )

-- Create a table for buttons pressed state
joystick_buttons_pressed = {}
for i = 1, joystick_buttons do
  table.insert(joystick_buttons_pressed ,0)
end

-- RUN
Main()

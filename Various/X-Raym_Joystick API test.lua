function Main()

  time = os.clock()
  
  joystick_button_mask = reaper.joystick_getbuttonmask( joystick_device )
  joystick_pov = reaper.joystick_getpov( joystick_device, 0 )
  
  joystick_x1_axis = reaper.joystick_getaxis( joystick_device, 0 )
  joystick_x2_axis = reaper.joystick_getaxis( joystick_device, 1 )
  joystick_y1_axis = reaper.joystick_getaxis( joystick_device, 2 )
  joystick_y2_axis = reaper.joystick_getaxis( joystick_device, 3 )
  reaper.joystick_update( joystick_device )
  
  
  reaper.defer( Main )
  
end

-- Create Joystick
index = 0
joystick_guid, joystick_name = reaper.joystick_enum( index )
joystick_device = reaper.joystick_create( joystick_guid )
joystick_buttons, joystick_axes, joystick_povs = reaper.joystick_getinfo( joystick_device )

-- RUN
Main()

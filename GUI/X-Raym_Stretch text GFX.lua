-- by X-Raym
-- Thread: https://forum.cockos.com/showthread.php?t=161769

window_w = 640
window_h = 270

function init(window_w, window_h, window_x, window_y, docked)
  gfx.setfont(1, "Arial", 257) -- Max seems 257. set big size to avoid aliasing as much as possible when stretching.
  gfx.init("Stretch text" , window_w, window_h, docked, window_x, window_y)  -- name,w,h,dockstate,xpos,ypos
end

-- DRAW IN GFX WINDOW
function run()
  char = gfx.getchar()
  
  str = "STRETTTTTCH"
  
  -- Draw on another blit dest than main == - 1
  temp_blit = 3
  gfx.dest = temp_blit
  gfx.x = 0
  gfx.y = 0
  
  -- Set blit buffer to the string size
  str_w, str_h = gfx.measurestr( str )
  gfx.setimgdim(3,str_w,str_h )
  
  -- Draw string to the blit buffer
  gfx.drawstr( str )
  
  -- Draw on main blit
  gfx.dest = -1
  gfx.blit( temp_blit, 1, 0, 0, 0, str_w, str_h, 0, 0, gfx.w, gfx.h, 0, 0 )
  
  -- Refresh UI
  gfx.update()
  if char ~= 27 or char < 0 then reaper.defer(run) else gfx.quit() end

end -- END DEFER

init(window_w, window_h)
run()

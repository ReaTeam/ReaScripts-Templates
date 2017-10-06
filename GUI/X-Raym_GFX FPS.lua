-- Ultra Basic GFX
-- For quick testing purposes

window_w = 640
window_h = 270
lasttime = 0
clock = 0
function init(window_w, window_h, window_x, window_y, docked)
	gfx.init("GFX" , window_w, window_h, docked, window_x, window_y)  -- name,w,h,dockstate,xpos,ypos
end

function Update()
  local newtime=os.time()
  if newtime-lasttime >= 1 then
    clock_hz = clock
    lasttime=newtime
    clock = 0
    -- do whatever you want to do every 10 seconds
  end
	clock = clock + 1
	gfx.update()
	if gfx.getchar() ~= 27 then reaper.defer(run) else gfx.quit() end
end

-- DRAW IN GFX WINDOW
function run()

	Update()

end -- END DEFER

init(window_w, window_h)
run()

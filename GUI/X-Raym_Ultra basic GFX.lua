-- Ultra Basic GFX
-- For quick testing purposes

window_w = 640
window_h = 270

function init(window_w, window_h, window_x, window_y, docked)
	gfx.init("GFX" , window_w, window_h, docked, window_x, window_y)  -- name,w,h,dockstate,xpos,ypos
end

-- DRAW IN GFX WINDOW
function run()
	char = gfx.getchar()
	
	
	gfx.update()
	if char ~= 27 or char < 0 then reaper.defer(run) else gfx.quit() end

end -- END DEFER

init(window_w, window_h)
run()

-----------------------------------------
-- SCRIPT 1 -- main script with graphics
-----------------------------------------
w = 150
function run()
  test = reaper.GetExtState( 'test_section', 'test_key' )
  val = tonumber(test)
  if not val or val < 0 then val = 0 end
  gfx.rect(0,0,w* val ,w,1)
  gfx.update()
  if gfx.getchar() ~= -1 then reaper.defer(run) end
end

gfx.init('test GetExtState',w,w, w)
run()
reaper.atexit(gfx.quit)


-----------------------------------------
-- SCRIPT 2 --bind it to MIDI or OSC control
-----------------------------------------

is_new_value,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context()
reaper.SetExtState( 'test_section', 'test_key', val/resolution, true )

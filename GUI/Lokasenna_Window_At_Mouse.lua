local function Window_At_Mouse (w, h)
  
  local mouse_x, mouse_y = reaper.GetMousePosition()
  local x, y = mouse_x - (w / 2), mouse_y - (h / 2)
  local l, t, r, b = x, y, x + w, y + h
  
  local __, __, screen_w, screen_h = reaper.my_getViewport(l, t, r, b, l, t, r, b, 1)
  
  if l < 0 then x = 0 end
  if r > screen_w then x = (screen_w - w - 16) end
  if t < 0 then y = 0 end
  if b > screen_h then y = (screen_h - h - 40) end

        gfx.init("My window", w, h, 0, x, y)  
  
end

Window_At_Mouse(100,50)

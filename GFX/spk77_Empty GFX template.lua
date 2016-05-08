-- From Lua: GUI/graphics related stuff - Cockos Confederated Forums
-- http://forum.cockos.com/showthread.php?t=161557

-- Empty GUI template

function msg(m)
  return reaper.ShowConsoleMsg(tostring(m) .. "\n")
end


-----------------
-- Mouse table --
-----------------

local mouse = {  
                  -- Constants
                  LB = 1,
                  RB = 2,
                  CTRL = 4,
                  SHIFT = 8,
                  ALT = 16,
                  
                  -- "cap" function
                  cap = function (mask)
                          if mask == nil then
                            return gfx.mouse_cap end
                          return gfx.mouse_cap&mask == mask
                        end,
                  
                  -- Returns true if LMB down, else false
                  lb_down = function() return gfx.mouse_cap&1 == 1 end,
                  
                  -- Returns true if RMB down, else false
                  rb_down = function() return gfx.mouse_cap&2 == 2 end,
       
                  uptime = 0,
                  
                  last_x = -1, last_y = -1,
                  
                  -- Updated when LMB/RMB down and mouse is moving.
                  -- Both values are set to 0 when LMB/RMB is released
                  dx = 0, 
                  dy = 0,
                  
                  ox = 0, oy = 0,    -- left/right click coordinates
                  cap_count = 0,
                  
                  last_LMB_state = false,
                  last_RMB_state = false
               }
          
---------------------------------------------------------------------------




----------------------------------
-- Mouse event handling         --
-- (from Schwa's GUI example)   --
----------------------------------

function OnMouseDown(x, y, lmb_down, rmb_down)
  -- LMB clicked
  if not rmb_down and lmb_down and mouse.last_LMB_state == false then
    mouse.last_LMB_state = true
  end
  -- RMB clicked
  if not lmb_down and rmb_down and mouse.last_RMB_state == false then
    mouse.last_RMB_state = true
  end
  mouse.ox, mouse.oy = x, y -- mouse click coordinates
  mouse.cap_count = 0       -- reset mouse capture count
end


function OnMouseUp(x, y, lmb_down, rmb_down)
  -- handle "mouse button up" here
  mouse.uptime = os.clock()
  mouse.dx = 0
  mouse.dy = 0
  -- left mouse button was released
  if not lmb_down and mouse.last_LMB_state then mouse.last_LMB_state = false end
  -- right mouse button was released
  if not rmb_down and mouse.last_RMB_state then mouse.last_RMB_state = false end
end


function OnMouseDoubleClick(x, y)
  -- handle mouse double click here
end


function OnMouseMove(x, y)
  -- handle mouse move here, use mouse.down and mouse.capcnt
  mouse.last_x, mouse.last_y = x, y
  mouse.dx = gfx.mouse_x - mouse.ox
  mouse.dy = gfx.mouse_y - mouse.oy
  mouse.cap_count = mouse.cap_count + 1
end



-------------------------------------------------------------------------------------------


----------
-- Init --
----------

-- GUI table ----------------------------------------------------------------------------------
--   contains GUI related settings (some basic user definable settings), initial values etc. --
-----------------------------------------------------------------------------------------------
local gui = {}

function init()
  
  -- Add stuff to "gui" table
  gui.settings = {}                 -- Add "settings" table to "gui" table 
  gui.settings.font_size = 20       -- font size
  gui.settings.docker_id = 0        -- try 0, 1, 257, 513, 1027 etc.
  
  ---------------------------
  -- Initialize gfx window --
  ---------------------------
  
  gfx.init("", 200, 200, gui.settings.docker_id)
  gfx.setfont(1,"Arial", gui.settings.font_size)
  gfx.clear = 3355443  -- matches with "FUSION: Pro&Clean Theme :: BETA 01" http://forum.cockos.com/showthread.php?t=155329
  -- (Double click in ReaScript IDE to open the link)

  mainloop()
end


--------------
-- Mainloop --
--------------

function mainloop()
  local LB_DOWN = mouse.lb_down()           -- current left mouse button state is stored to "LB_DOWN"
  local RB_DOWN = mouse.rb_down()           -- current right mouse button state is stored to "RB_DOWN"
  local mx, my = gfx.mouse_x, gfx.mouse_y   -- current mouse coordinates are stored to "mx" and "my"
  
  -- (modded Schwa's GUI example)
  if (LB_DOWN and not RB_DOWN) or (RB_DOWN and not LB_DOWN) then   -- LMB or RMB pressed down?
    if (mouse.last_LMB_state == false and not RB_DOWN) or (mouse.last_RMB_state == false and not LB_DOWN) then
      OnMouseDown(mx, my, LB_DOWN, RB_DOWN)
      if mouse.uptime and os.clock() - mouse.uptime < 0.20 then
        OnMouseDoubleClick(mx, my)
      end
    elseif mx ~= mouse.last_x or my ~= mouse.last_y then
      OnMouseMove(mx, my)
    end
      
  elseif not LB_DOWN and mouse.last_RMB_state or not RB_DOWN and mouse.last_LMB_state then
    OnMouseUp(mx, my, LB_DOWN, RB_DOWN)
  end

  --------------
  -- Draw GUI --
  --------------
  
  gfx.x = 10
  gfx.y = 10
  gfx.printf("GUI template")
 
  gfx.update()
  if gfx.getchar() >= 0 then reaper.defer(mainloop) end
end

init()

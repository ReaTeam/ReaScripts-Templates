-- Improved roundrect() function with fill, adapted from mwe's EEL example.
-- Alpha support by X-Raym + fixed circles positions
-- color is taken from gfx.r, gfx.g, gfx.b
local function roundrect2(x, y, w, h, r, antialias, fill, alpha )
  local aa = antialias or 1
  fill = fill or 0
  
  gfx.setimgdim( 10, 0, 0 )
  gfx.setimgdim( 10, gfx.w, gfx.h )
  
  gfx.set( gfx.r, gfx.g, gfx.b, 1, 0, 10 )
  
  if fill == 0 or false then
    gfx.roundrect(x, y, w, h, r, aa)
  end
  
  x = math.floor( x + 0.5 )
  y = math.floor( y + 0.5 )
  w = math.floor( w + 0.5 )
  h = math.floor( h + 0.5 )
  
  if h >= 2 * r and w >= 2 * r then
    -- Corners
    gfx.circle(x + r, y + r, r, 1, aa)      -- top-left
    gfx.circle(x + w - r+1, y + r, r, 1, aa)    -- top-right
    gfx.circle(x + w - r+1, y + h - r, r , 1, aa)  -- bottom-right
    gfx.circle(x + r, y + h - r, r, 1, aa)    -- bottom-left
    
    -- Ends
    gfx.rect(x, y + r, r, h - r * 2)
    gfx.rect(x + w - r + 1, y + r, r + 1, h - r * 2)
      
    -- Body + sides
    gfx.rect(x + r, y, w - r * 2 + 1, h + 1.5)

  else
    r = math.floor( math.min( w / 2, h / 2 ) - 0.5 )

    if w < h then
      gfx.circle(x + r, y + r, r, 1, aa)
      gfx.circle(x + r, y - r + h, r, 1, aa)
      gfx.rect(x, y+r, w, h - r * 2)

    else
      gfx.circle(x + r, y + r, r, 1, aa)
      gfx.circle(x + w - r, y + r, r, 1, aa)
      gfx.rect(x + r, y, w - r * 2, h)
    end
    
  end

  gfx.dest = -1
  gfx.a = alpha or 1
  gfx.blit(10, 1, 0, 0, 0, gfx.w, gfx.h, 0, 0, gfx.w, gfx.h )
end

function init(window_w, window_h, window_x, window_y, docked)
  gfx.init("GFX" , window_w, window_h, docked, window_x, window_y)  -- name,w,h,dockstate,xpos,ypos
end

-- Ultra Basic GFX
-- For quick testing purposes

window_w = 640
window_h = 270

-- DRAW IN GFX WINDOW
function run()
  char = gfx.getchar()
  
  --gfx.roundrect( math.floor(gfx.w / 4), math.floor(gfx.h / 4), math.floor(gfx.w / 2), math.floor(gfx.h / 2), 10, true)
  gfx.r = 0.5
  --roundrect2( gfx.w // 4 | 0, gfx.h // 4 | 0, gfx.w // 2 | 0, gfx.h // 2 | 0, 100, true, true, 0.5)
  a_x = gfx.w // 2.5 | 0
  a_y = gfx.h // 8 | 0
  a_w = gfx.w // 4 | 0
  a_h =  gfx.h // 1.25 | 0
  roundrect2( a_x, a_y, a_w, a_h, 50, true, true, 0.5)
  
  --RoundRect( gfx.w // 2.5 | 0, gfx.h // 8 | 0, gfx.w // 4 | 0, gfx.h // 1.25 | 0, 100, 1, 1, 0.5)
  
  gfx.update()
  if char ~= 27 or char < 0 then reaper.defer(run) else gfx.quit() end

end -- END DEFER

init(window_w, window_h)
run()

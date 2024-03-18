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
  
  if h >= 2 * r and w >= 2 * r then
    -- Corners
    gfx.circle(x + r, y + r, r, 1, aa)      -- top-left
    gfx.circle(x + w - r, y + r, r, 1, aa)    -- top-right
    gfx.circle(x + w - r, y + h - r, r , 1, aa)  -- bottom-right
    gfx.circle(x + r, y + h - r, r, 1, aa)    -- bottom-left
    
    -- Ends
    gfx.rect(x, y + r, r, h - r * 2)
    gfx.rect(x + w - r + 1, y + r, r + 1, h - r * 2)
      
    -- Body + sides
    gfx.rect(x + r, y, w - r * 2 + 1, h + 1.5)

  else
    r = math.min( w / 2 - 1, h / 2 - 1 )

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

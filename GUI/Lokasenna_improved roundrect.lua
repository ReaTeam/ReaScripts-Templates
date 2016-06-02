--[[
  Wrapper for gfx.roundrect() with optional fill,
  adapted from mwe's EEL example on the forum.
  
  by Lokasenna
]]--

local function roundrect(x, y, w, h, r, fill, antialias)
	
	local aa = antialias or 1
	
	-- If we aren't filling it in, the original function is fine
	if fill == 0 or false then
		gfx.roundrect(x, y, w, h, r, aa)
		
	else
		
		-- Corners
		gfx.circle(x + r, y + r, r, 1, aa)
		gfx.circle(x + w - r, y + r, r, 1, aa)
		gfx.circle(x + w - r, y + h - r, r , 1, aa)
		gfx.circle(x + r, y + h - r, r, 1, aa)
		
		-- Ends
		gfx.rect(x, y + r, r, h - r * 2)
		gfx.rect(x + w - r, y + r, r + 1, h - r * 2)
			
		-- Body + sides
		gfx.rect(x + r, y, w - r * 2, h + 1)
	end	
	
end

-- Using gfx.triangle (no anti-aliaising)
function gfx_line_bold(x1, y1, x2, y2, w)
  local xn, yn = (x2 - x1)*-1, y2 - y1
  local l = math.sqrt(xn * xn + yn * yn)
  xn, yn = xn/l, yn/l
  local t = xn; xn = yn; yn = t
  local p1x, p1y, p2x, p2y = x1 - xn*w, y1 - yn*w, x1 + xn*w, y1 + yn*w
  local p3x, p3y, p4x, p4y = x2 - xn*w, y2 - yn*w, x2 + xn*w, y2 + yn*w
  gfx.triangle(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y)
end

-- using lines (less efficient but anti aliased)
function gfx_line_bold2(x1, y1, x2, y2, w)
  local xn, yn = (x2 - x1)*-1, y2 - y1
  local l = math.sqrt(xn * xn + yn * yn)
  xn, yn = xn/l, yn/l
  local t = xn; xn = yn; yn = t; 
  local i, fill = 0, 4;
  while i <= w do
    gfx.line(x1 + xn*i, y1 + yn*i, x2 + xn*i, y2 + yn*i)
    gfx.line(x1 - xn*i, y1 - yn*i, x2 - xn*i, y2 - yn*i)
    i = i + 1/fill
  end
end

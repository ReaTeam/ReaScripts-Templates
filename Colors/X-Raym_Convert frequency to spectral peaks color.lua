function MapLinear (num, in_min, in_max, out_min, out_max)
  return (num - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

_, h_offset = reaper.get_config_var_string( "specpeak_huel" )
h_offset = MapLinear(tonumber(h_offset%1+0.06), 0,1,0,360) -- 0.06 is a manual offset
s = 1.5
l = 0.5
a = 1

-- COLORS -------------------------------------------------------------

-- From https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua

function hue2rgb(p, q, t)
  if t < 0   then t = t + 1 end
  if t > 1   then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end

--[[
 * Converts an HSL color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes h, s, and l are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  l       The lightness
 * @return  Array           The RGB representation
]]
function hslToRgb(h, s, l, a)
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else

    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end
  r = math.floor((r * 255) + 0.5)
  g = math.floor((g * 255) + 0.5)
  b = math.floor((b * 255) + 0.5)
  return r, g, b, a * 255
end

-- Thanks Lokasenna!
-- Map a 20-20000 number into a 0-360 interval logarythmicly
-- close enough approach
function map(x)
  return 52.1153 * math.log(0.05 * x)
end

function UpdateColorFromFreq( freq )
  local h = (map(freq) + h_offset)/360
  local color_a = table.pack(hslToRgb(h, s, l, a))
  gfx.r, gfx.g, gfx.b = color_a[1]/360, color_a[2]/360, color_a[3]/360
end

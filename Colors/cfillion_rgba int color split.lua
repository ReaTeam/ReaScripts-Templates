-- the floating point conversion and / 255 may lead to precision loss
-- if all you need is converting from little to big endian (0xAABBGGRR -> 0xRRGGBBAA), then this should do the trick:

local function bswap(integer)
  return
    (integer >> 24 & 0x000000FF) |
    (integer >> 8  & 0x0000FF00) |
    (integer << 8  & 0x00FF0000) |
    (integer << 24 & 0xFF000000)
end

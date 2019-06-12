min_freq = 80
max_freq = 1000
Thresh_dB = -40
min_tonal = 0.85

function MapLinear (num, in_min, in_max, out_min, out_max)
  return (num - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

_, h_offset = reaper.get_config_var_string( "specpeak_huel" )
h_offset = MapLinear(tonumber(h_offset%1+0.06), 0,1,0,360) -- 0.06 is a manual offset
s = 1
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
  gfx.r, gfx.g, gfx.b = color_a[1]/255, color_a[2]/255, color_a[3]/255
end

------------------------------------------------------------
function Init()
    -- Some gfx Wnd Default Values ---------------
    local Wnd_bgd = 0x0F0F0F  
    local Wnd_Title = "Test"
    local Wnd_Dock,Wnd_X,Wnd_Y = 0,100,320 
    Wnd_W,Wnd_H = 1044,490 -- global values(used for define zoom level)
    -- Init window ------
    gfx.clear = Wnd_bgd         
    gfx.init( Wnd_Title, Wnd_W,Wnd_H, Wnd_Dock, Wnd_X,Wnd_Y )  
end

------------------------------------------------------------
function Peaks_Draw(Peaks)
  local min_note = 69 + 12 * math.log(min_freq/440, 2)
  local max_note = 69 + 12 * math.log(max_freq/440, 2)
  local Thresh = 10 ^ (Thresh_dB/20)
  ----------------------
  local axis = gfx.h * 0.5
  local Ky = gfx.h * 0.5
  local Kn = gfx.h/(max_note-min_note)
  local offs = min_note * Kn
  ----------------------
  local abs, max = math.abs, math.max
  for i = 1, #Peaks, 4 do
    local max_peak, min_peak = Peaks[i], Peaks[i+1]
    local xx = i/4
    gfx.set(0,0.5,0,1)
    UpdateColorFromFreq( Peaks[i+2])
    gfx.line(xx , axis - max_peak*Ky, xx, axis - min_peak*Ky, true) -- Peaks   
    --[[ 
    if max(abs(max_peak), abs(min_peak)) > Thresh then
      local freq, tonal = Peaks[i+2], Peaks[i+3]
      local note = 69 + 12 * math.log(freq/440, 2)  
      if tonal >= min_tonal and note >= min_note and note <= max_note then
        gfx.x = xx; gfx.y = gfx.h + offs - note*Kn;
        gfx.setpixel(1,0,0)
      elseif note < min_note then
        gfx.x = xx; gfx.y = gfx.h - 10;
        gfx.setpixel(0,0,1)
      elseif note > max_note then
        gfx.x = xx; gfx.y = 10;
        gfx.setpixel(0,1,1)
      end
    end
    ]]
  end
   
end
------------------------------------------------------------
function Item_GetPeaks(item)
  if not item then return end
  local take = reaper.GetActiveTake(item)
  if not take or reaper.TakeIsMIDI(take) then return end
  local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  local sel_start, sel_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  if sel_end - sel_start == 0 then sel_start = item_start; sel_end = item_start + item_len end
  
  local starttime = math.max(sel_start, item_start)
  local len = math.min(sel_end, item_start + item_len) - starttime
  if len <= 0 then return end 
  ------------------
  --PCM_Source = reaper.GetMediaItemTake_Source(take)
  local n_chans = 1   -- I GetPeaks Only from 1 channel!!!
  local peakrate = gfx.w / len
  local n_spls = math.floor(len*peakrate + 0.5) -- its Peak Samples         
  local want_extra_type = 115  -- 's' char
  local buf = reaper.new_array(n_spls * n_chans * 3) -- max, min, spectral each chan(but now 1 chan only)
  buf.clear()         -- Clear buffer
  ------------------
  local retval = reaper.GetMediaItemTake_Peaks(take, peakrate, starttime, n_chans, n_spls, want_extra_type, buf);
  local spl_cnt  = (retval & 0xfffff)        -- sample_count
  local ext_type = (retval & 0x1000000)>>24  -- extra_type was available
  local out_mode = (retval & 0xf00000)>>20   -- output_mode
  ------------------
  local Peaks = {}
  if spl_cnt > 0 and ext_type > 0 then
    for i = 1, n_spls do
      local p = #Peaks
      Peaks[p+1] = buf[i]             -- max peak
      Peaks[p+2] = buf[n_spls + i]    -- min peak
      --------------
      local spectral = buf[n_spls*2 + i]    -- spectral peak
      -- freq and tonality from spectral peak --
      Peaks[p+3] = spectral&0x7fff       -- low 15 bits frequency
      Peaks[p+4] = (spectral>>15)/16384  -- tonality norm value 
    end
  end
  ------------------
  return Peaks
end

---------------------------
function Project_IsChanged()
    local cur_cnt = reaper.GetProjectStateChangeCount(0)
    if cur_cnt ~= proj_change_cnt then proj_change_cnt = cur_cnt
       return true  
    end
end

---------------------------
function main()    
    if Project_IsChanged() then
      gfx.setimgdim(0, 0, 0) -- clear buf 0
      gfx.setimgdim(0, gfx.w, gfx.h)
      gfx.dest = 0; -- set dest buf = 0   
      local item = reaper.GetSelectedMediaItem(0, 0) 
      if item then
        local Peaks = Item_GetPeaks(item) 
        if Peaks then Peaks_Draw(Peaks) end
      end 
    end
    -----------
    local img_w, img_h = gfx.getimgdim(0)
    if img_w > 0 and img_h > 0 then
      gfx.a = 1; gfx.dest = -1; gfx.x, gfx.y = 0, 0
      gfx.blit(image, 1, 0, 0, 0, img_w, img_h, 0, 0, gfx.w, gfx.h)
    end
    ----------- 
    char = gfx.getchar() 
    if char == 32 then reaper.Main_OnCommand(40044, 0) end -- play
    if char ~= -1 then reaper.defer(main) end              -- defer       
    -----------  
    gfx.update()
    -----------
end

Init()
main()

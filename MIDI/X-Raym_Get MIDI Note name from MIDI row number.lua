-- This version is way more concize

--[[
number: integer, MIDI row, between 0 and 127
offset: integer, octave offset
flat: bolean, sharp by default, flat if true
idx: bolean, have the number in three digits form as prefix (useful for sorting)
]]--
function GetMIDINoteName(number, offset, flat, idx)
  if 0 < number and number > 127 then return "" end
  local note = number % 12
  local note_names = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }
  local note_names_flat = { "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B" }
  local note_name = flat and note_names_flat[note + 1] or note_names[note + 1]
  local octave = math.floor( number / 12 ) + (offset or 0)
  local note_id = idx and string.format( "%03d-", number) or ""
  return note_id .. note_name .. octave
end


-- Get MIDI Note name from a MIDI row.
--[[
number: integer, MIDI row, between 0 and 127
offset: integer, octave offset
flat: bolean, sharp by default, flat if true
idx: bolean, have the number in three digits form as prefix (useful for sorting)
]]--
function GetMIDINoteName(number, offset, flat, idx)

  local output

  if 0 <= number and number <= 127 then
    
    -- OCTAVE
    local octave = math.floor(number/12)
    if offset then
      octave = octave + math.floor(offset)
    end
    
    -- KEY
    local key = number % 12
    
    if key == 0 then key = "C"
    elseif key == 1 then
      if not flat then key = "C#" else key = "Db" end
    elseif key == 2 then key = "D"
    elseif key == 3 then
      if not flat then key = "D#" else key = "Eb" end
    elseif key == 4 then key = "E"
    elseif key == 5 then key = "F"
    elseif key == 6 then 
      if not flat then key = "F#" else key = "Gb" end
    elseif key == 7 then key = "G"
    elseif key == 8 then
      if not flat then key = "G#" else key = "Ab" end
    elseif key == 9 then key = "A"
    elseif key == 10 then
      if not flat then key = "A#" else key = "Bb" end
    elseif key == 11 then key = "B"
    else key = nil end
    
    -- OUTPUT
    output = key .. octave
    
    if idx then
      local prefix = tostring(number)
      
      local length = string.len(number)
      if length == 1 then prefix = "00" .. prefix
      elseif length == 2 then prefix = "0" .. prefix end

      output = prefix .. "-" .. output  
    end
  
  end
  
  return output
  
end


-- INIT

note = {}
for i = 1, 127 do
  note[i] = GetMIDINoteName(i-1, 2, true, true)
end

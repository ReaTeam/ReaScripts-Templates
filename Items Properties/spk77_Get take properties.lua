-- Get take source properties from first selected item (from active take)
function get_take_properties()
  
  local item = reaper.GetSelectedMediaItem(0,0) -- get first selected item
  -- No selected items
  if item == nil then
    msg("No item selected")
  return false end
  
  -- Empty item (no takes in item)
  local take = reaper.GetActiveTake(item)
  if take == nil then
    msg("Empty item?")
  return false end
  
  -- Active take in selected item is a MIDI take
  if reaper.TakeIsMIDI(take) then
    msg("Please select an audio take")
  return false end

  -- create "SourceProperties" array 
  --ret, section, start, length, fade, reverse = reaper.BR_GetMediaSourceProperties(take)
  local t = {}
  local ret = false
  ret, t.section, t.start, t.length, t.fade, t.reverse = reaper.BR_GetMediaSourceProperties(take)
  if ret == false then
    return false
  end
  
  
    
  -- A hack: if "section" or "reverse" is true, "GetMediaSourceFileName" returns an empty string.
  -- both has to be set to "false" (temporarily) to get the source file name
  if t.section == true or t.reverse == true then
    -- set "section" and "reverse" to "false"
    reaper.BR_SetMediaSourceProperties(take, false, t.start, t.length, t.fade, false)
    t.take_source = reaper.GetMediaItemTake_Source(take) -- get media source
    t.take_source_filename = reaper.GetMediaSourceFileName(t.take_source, "")  -- get media source filename
     -- set "section" and "reverse" back to original states
    reaper.BR_SetMediaSourceProperties(take, t.section, t.start, t.length, t.fade, t.reverse)
  else
    t.take_source = reaper.GetMediaItemTake_Source(take)
    t.take_source_filename = reaper.GetMediaSourceFileName(t.take_source, "")
  end
  
  return t
end


-- Test:
-- Store take_properties to "take_properties" table
take_properties = get_take_properties()

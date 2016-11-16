count_items = reaper.CountSelectedMediaItems( 0 )

for i = 0, count_items - 1 do
  local item = reaper.GetSelectedMediaItem( 0, i )
  local take = reaper.GetActiveTake( item )
  local retval =  reaper.MIDI_InsertNote( take, selected, muted, startppqpos, endppqpos, chan, pitch, vel, noSortIn )
  reaper.MIDI_Sort( take ) -- use noSortIn = true foor multiple notes insertion, should be not needed if noSortIn false if one note insertion
end

reaper.UpdateArrange()

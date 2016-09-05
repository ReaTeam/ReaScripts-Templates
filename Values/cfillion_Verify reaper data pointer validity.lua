// http://forum.cockos.com/showpost.php?p=1666283&postcount=3
// You can check whether a value is an actual take using ValidatePtr:

local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())

if reaper.ValidatePtr(take, 'MediaItem_Take*') then
  reaper.ShowConsoleMsg("take is valid\n")
else
  reaper.ShowConsoleMsg("not a take\n")
end


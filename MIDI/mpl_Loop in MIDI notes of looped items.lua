function m(s) reaper.ShowConsoleMsg(s..'\n') end
function GetLoopedMIDINotes(item)
    
    -- Get Item Infos
    local item_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION'  )
    local item_len = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH'  )      
    local take =  reaper.GetActiveTake( item )
    local take_offs = reaper.GetMediaItemTakeInfo_Value( take, 'D_STARTOFFS' ) --NOTE: This should have to be taken into account later
    
    -- Get Item Source Infos
    local src = reaper.GetMediaItemTake_Source( take )
     src_lenQN = reaper.GetMediaSourceLength( src ) 
     item_stQN = reaper.TimeMap_timeToQN_abs( 0, item_pos)
    local item_endQN = reaper.TimeMap_timeToQN_abs( 0, item_pos+item_len )
    local item_lenQN = item_endQN-item_stQN  
    src_lenPPQ = reaper.MIDI_GetPPQPosFromProjQN( take, src_lenQN+item_stQN)
        
    -- ok here is how many loop slices you have:
    local  scr_mult = math.ceil(item_lenQN / src_lenQN) -1
    
    local t = {} -- Master tabe containing all Notes of all src
    for i = 1, scr_mult do
      local note_edit = GetNoteTable(take)
      for j = 1, #note_edit do 
        test = note_edit[j].startppqpos +src_lenPPQ*(i-1)
        note_edit[j].startppqpos1 = test end
      t[#t+1] = note_edit
    end
    return t
end

-- Loop in Take Notes and Return Table of Notes with Infos
function  GetNoteTable(take)
    local _, notecntOut, _, _ = reaper.MIDI_CountEvts( take )
    local note = {}
    for i = 1, notecntOut do
      note[i] = {}
        _, note[i].selectedOut, 
        note[i].mutedOut, 
        note[i].startppqpos, 
        note[i].endppqpos, 
        note[i].chanOut, 
        note[i].pitchOut, 
        note[i].velOut = reaper.MIDI_GetNote( take, i-1 )        
    end
    return note
end




-- Get first selected item
local item =  reaper.GetMediaItem( 0, 0 )
local take =  reaper.GetActiveTake( item )
t = GetLoopedMIDINotes(item)
reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWSMARKERLIST9'),0) -- delete all markers
for i = 1, #t do
  for j = 1, #t[i] do
    pos =  reaper.MIDI_GetProjTimeFromPPQPos( take, t[i][j].startppqpos1)
    reaper.AddProjectMarker( 0, false, pos, -1, 1, -1)
  end
end

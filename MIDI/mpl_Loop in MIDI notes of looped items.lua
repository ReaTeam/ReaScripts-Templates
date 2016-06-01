function GetLoopedMIDINotes(item)
    
    -- Get Item Infos
    local item_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION '  )
    local item_len = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH'  )      
    local take =  reaper.GetActiveTake( item )
    local take_offs = reaper.GetMediaItemTakeInfo_Value( take, 'D_STARTOFFS' ) --NOTE: This should have to be taken into account later
    
    -- Get Notes Infos
    note = GetNoteTable(take, ppq_offset)

    
    -- Get Item Source Infos
    local src = reaper.GetMediaItemTake_Source( take )
    local src_lenQN = reaper.GetMediaSourceLength( src ) 
    local item_stQN = reaper.TimeMap_timeToQN_abs( 0, item_pos+take_offs)
    local item_endQN = reaper.TimeMap_timeToQN_abs( 0, take_offs+item_pos+item_len )
    local item_lenQN = item_endQN-item_stQN  
    
    -- ok here is how many loop slices you have:
    local  scr_mult = math.ceil(item_lenQN / src_lenQN)
    
    local t = {} -- Master tabe containing all Notes of all src
    for i = 1, scr_mult do
       -- add source midi table to each loop sourced item, calc PPQ from QN of start each loop, use takeoffsetQN converted also
       -- HERE I`M SCARED and let this code fly to your post
       table.insert(note, )
    end
    return t
end

-- Loop in Take Notes and Return Table of Notes with Infos
function  GetNoteTable(take, ppq_offset)
    local _, notecntOut, _, _ = reaper.MIDI_CountEvts( take )
    local note = {}
    for i = 1, notecntOut do
      note[i] = {}
        _, note[i].selectedOut, 
        note[i].mutedOut, 
        note[i].startppqposOut, 
        note[i].endppqposOut, 
        note[i].chanOut, 
        note[i].pitchOut, 
        note[i].velOut = reaper.MIDI_GetNote( take, i-1 )
        note[i].startppqposOutQN =  reaper.MIDI_GetProjQNFromPPQPos( take, note[i].startppqposOut )
        note[i].endppqposOutQN =  reaper.MIDI_GetProjQNFromPPQPos( take, note[i].endppqposOut )
    end
    return note
end

-- Get first selected item
local item =  reaper.GetMediaItem( 0, 0 )
if not item then return end
t = GetLoopedMIDINotes(item)


-- Create one marker for each note position in table
for i, single in pairs(note) do
    pos = reaper.TimeMap2_QNToTime(0, single.startppqposOutQN)
    reaper.AddProjectMarker( 0, false, pos, -1, i, -1)
end

--[[    Working with audio in ReaScript
    
    This template was adapted from eugen2777's "Create stretch markers at transients"
    EEL script. Cheers to him.    
    
]]--

local item = reaper.GetSelectedMediaItem(0, 0)

if not item then
    reaper.MB("No item selected", "Oops", 0)
    return
end

local take = reaper.GetActiveTake(item)
local PCM_source = reaper.GetMediaItemTake_Source(take)
local samplerate = reaper.GetMediaSourceSampleRate(PCM_source)

if not samplerate then
    reaper.MB("Couldn't access the item. Maybe it's not audio?", "Oops", 0)
    return
end


-- Perform some sort of action based on the audio in the selected take
-- (within the current time selection, if any)
local function IterateSamples(item, take, samplerate)


    ------------------------------------
    -------- Prepping some values ------
    ------------------------------------


    -- It's significantly faster to use locals for CPU-intensive tasks
    local GetSamples = reaper.GetAudioAccessorSamples
    local reaper = reaper
    

    -- Sort out the selection range
    local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local sel_start, sel_end = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
    if not sel_start or sel_end == sel_start then
        sel_start = item_start
        sel_end = item_start + item_len
    end
    
    sel_start = math.max(sel_start, item_start)
    sel_end = math.min(sel_end, item_start + item_len)
    if sel_end - sel_start < 0 then
        reaper.ShowMessageBox("Time selection out of item range!", "Note", 0)
    end
    
    -- Make sure the selection is coherent
    if sel_end - sel_start <= 0 then return nil end


    -- Math is much easier if we convert to playrate == 1
    -- Don't worry, we'll put everything back afterward
    local playrate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
    if playrate ~= 1 then
        reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", 1)
        reaper.SetMediaItemInfo_Value(item, "D_LENGTH", item_len * playrate)
    end
    
    -- Define the time range w.r.t the original playrate
    local range_start = (sel_start - item_start) * playrate
    local range_len = (sel_end - sel_start) * playrate
    local range_end = range_start + range_len
    local range_len_spls = math.floor(range_len * samplerate)

    -- Break the range into blocks
    local block_size = 65536    
    local n_blocks = math.floor(range_len_spls / block_size)
    local extra_spls = range_len_spls - block_size * n_blocks


    -- 'samplebuffer' will hold all of the audio data for each block
    local samplebuffer = reaper.new_array(block_size * 1)
    local audio = reaper.CreateTakeAudioAccessor(take)


    -- Loop through the audio, one block at a time
    local starttime_sec = range_start
    for cur_block = 0, n_blocks do

        -- The last iteration will almost never be a full block
        if cur_block == n_blocks then block_size = extra_spls end
        
        samplebuffer.clear()
        
        -- Loads 'samplebuffer' with the next block
        GetSamples(audio, samplerate, 1, starttime_sec, block_size, samplebuffer)

        local spl
        for i = 1, block_size do
            
            spl = samplebuffer[i]
            
            ------------------------------------
            -------- Do whatever you want ------
            -------- with the sample here ------
            ------------------------------------

            
        end
        
        starttime_sec = starttime_sec + (65536 / samplerate)

    end
    

    -- Tell Reaper we're done working with this item, so the memory can be freed
    reaper.DestroyAudioAccessor(audio)
    
    -- I told you we'd put everything back
    if playrate ~= 1 then
        
        reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", playrate)
        reaper.SetMediaItemInfo_Value(item, "D_LENGTH", item_len)
        
    end
    
    -- Item changes frequently don't prompt Reaper to redraw automatically
    reaper.UpdateTimeline()
    
end

IterateSamples()
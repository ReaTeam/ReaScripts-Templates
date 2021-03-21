--[[    Working with audio in ReaScript
    
    This template was adapted from eugen2777's "Create stretch markers at transients"
    EEL script. Cheers to him.    
    
]]--

local function Msg(str)
   reaper.ShowConsoleMsg(tostring(str).."\n") 
end



-- Perform some sort of action based on the audio in the selected take
-- (within the current time selection, if any)
local function IterateSamples()


    ------------------------------------
    -------- Basic item info -----------
    ------------------------------------
    
    
    local item = reaper.GetSelectedMediaItem(0, 0)

    if not item then
        reaper.MB("No item selected", "Oops", 0)
        return nil
    end

    local take = reaper.GetActiveTake(item)
    local PCM_source = reaper.GetMediaItemTake_Source(take)
    local samplerate = reaper.GetMediaSourceSampleRate(PCM_source)

    if not samplerate then
        reaper.MB("Couldn't access the item. Maybe it's not audio?", "Oops", 0)
        return nil
    end

    Msg("Sample rate: "..samplerate)
    

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

    -- Allow for multichannel audio
    local n_channels = reaper.GetMediaSourceNumChannels(PCM_source)    

    Msg("Channels: "..n_channels)

    -- 'samplebuffer' will hold all of the audio data for each block
    local samplebuffer = reaper.new_array(block_size * n_channels)
    local audio = reaper.CreateTakeAudioAccessor(take)


    -- Not important; just for benchmarking
    local t1 = reaper.time_precise()
    local num_samples = 0

    Msg("\nIterating...")


    -- Loop through the audio, one block at a time
    local starttime_sec = range_start
    for cur_block = 0, n_blocks do

        -- The last iteration will almost never be a full block
        if cur_block == n_blocks then block_size = extra_spls end
        
        samplebuffer.clear()    
        
        -- Loads 'samplebuffer' with the next block
        GetSamples(audio, samplerate, n_channels, starttime_sec, block_size, samplebuffer)

        -- amagalma note: Storing the buffer to a Lua table speeds up access times by 4x-6x times!!
        local temp = samplebuffer.table()
        
        -- Loop through each channel separately
        for i = 1, n_channels do

            for j = 1, block_size do
                
                -- Sample position in the block
                local pos = (j - 1) * n_channels + i   
                
                local spl = temp[pos] -- accessing a lua table is way faster than a reaper.array!
                
                --[[
                    The algorithm here should iterate through all the samples in
                    one channel of a block, then the next, etc, until the end of
                    the block is reached. Then it should move to the next block
                    and start again. i.e. for a block size of 4:
                    
                    1
                    3
                    5
                    7
                        2
                        4
                        6
                        8
                    
                    1
                    2
                    3
                    4
                    ...
                ]]--
                
                ------------------------------------
                -------- Do stuff with the ---------
                -------- the sample here -----------
                ------------------------------------

                    
                num_samples = num_samples + 1
                
            end
            
        end
        
        starttime_sec = starttime_sec + ((block_size * n_channels) / samplerate)

    end

    Msg("Done!\n")
    
    Msg("Iterated over "..tostring(num_samples).." samples")
    Msg("Elapsed time: "..(reaper.time_precise() - t1).." seconds")
    

    -- Tell Reaper we're done working with this item, so the memory can be freed
    reaper.DestroyAudioAccessor(audio)
    
    -- I told you we'd put everything back
    if playrate ~= 1 then
        
        reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", playrate)
        reaper.SetMediaItemInfo_Value(item, "D_LENGTH", item_len)
        
    end
    
    -- Item changes frequently don't prompt Reaper to redraw automatically
    reaper.UpdateTimeline()
    
    -- We don't seem to have had any errors, so...
    return true
    
end

IterateSamples()

--[[    Working with audio in ReaScript (using ImGui CreateFunctionFromEEL)
    
    Msg from amagalma:
    
    This template was adapted from Lokasenna's template, and uses cfillion's CreateFunctionFromEEL which
    requires ReaImGui 0.8.5+
    
    It is almost as fast as the EEL version (which is 7 times faster than its LUA counterpart!)
    
]]--


local function Msg(str)
   reaper.ShowConsoleMsg(tostring(str).."\n") 
end


-- Function to read the array usinf EEL
local ReadArrayWithEEL = reaper.ImGui_CreateFunctionFromEEL([[
i=0;
loop(block_size,

    // Loop through each channel separately
    j=1;
    loop(n_channels,
    
        spl = samplebuffer[i*n_channels+j];


        //
        //
        //  Do whatever you want
        //  with the sample here
        //
        //
        num_samples += 1;
    
        j+=1;
    );
    
    i+=1;  
    
);]])


-- making math function local improves their speed
local max, min, floor = math.max, math.min, math.floor


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
    

    -- Sort out the selection range
    local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local sel_start, sel_end = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
    if not sel_start or sel_end == sel_start then
        sel_start = item_start
        sel_end = item_start + item_len
    end
    
    sel_start = max(sel_start, item_start)
    sel_end = min(sel_end, item_start + item_len)
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
    local range_len_spls = floor(range_len * samplerate)


    -- Break the range into blocks
    local block_size = 65536    
    local n_blocks = floor(range_len_spls / block_size)
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
    local step_time = block_size/samplerate
    for cur_block = 0, n_blocks do

        -- The last iteration will almost never be a full block
        if cur_block == n_blocks then 
            block_size = extra_spls
            step_time = block_size/samplerate
        end
        
        samplebuffer.clear()    
        
        -- Loads 'samplebuffer' with the next block
        reaper.GetAudioAccessorSamples(audio, samplerate, n_channels, starttime_sec, block_size, samplebuffer)

        -- Use EEL to read from the array
        reaper.ImGui_Function_SetValue(ReadArrayWithEEL, 'block_size', block_size)
        reaper.ImGui_Function_SetValue(ReadArrayWithEEL, 'n_channels', n_channels)
        reaper.ImGui_Function_SetValue_Array(ReadArrayWithEEL, 'samplebuffer', samplebuffer)
        reaper.ImGui_Function_SetValue(ReadArrayWithEEL, 'samplerate', samplerate)
        reaper.ImGui_Function_Execute(ReadArrayWithEEL)
        starttime_sec = starttime_sec + step_time
        num_samples = reaper.ImGui_Function_GetValue(ReadArrayWithEEL, 'num_samples')
        
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

function msg(m)
  return reaper.ShowConsoleMsg(tostring(m) .. "\n")
end


function go_to_peak_sample()
  local item = reaper.GetSelectedMediaItem(0, 0)
  if item == nil then
    msg("No item selected")
    return
  end
  local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local item_vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")
  
  local take = reaper.GetActiveTake(item)
  if take == nil then
    msg("Not a valid take")
    return
  end
  
  -- Get media source of media item take
  local take_pcm_source = reaper.GetMediaItemTake_Source(take)
  if take_pcm_source == nil then
    return
  end
  
  -- Create take audio accessor
  local aa = reaper.CreateTakeAudioAccessor(take)
  if aa == nil then
    return
  end
  
  -- Get the start time of the audio that can be returned from this accessor
  local aa_start = reaper.GetAudioAccessorStartTime(aa)
  -- Get the end time of the audio that can be returned from this accessor
  local aa_end = reaper.GetAudioAccessorEndTime(aa)
  
  
  -- Get the length of the source media. If the media source is beat-based,
  -- the length will be in quarter notes, otherwise it will be in seconds.
  local take_source_len, length_is_QN = reaper.GetMediaSourceLength(take_pcm_source)
  if length_is_QN then
    return
  end
  
  -- Get the number of channels in the source media.
  local take_source_num_channels = reaper.GetMediaSourceNumChannels(take_pcm_source)
  --if take_source_num_channels > 1 then
    --msg("Please select a mono take")
    --return
  --end
  local channel_data = {} -- max peak values (per channel) are collected to this table
  for i=1, take_source_num_channels do
    channel_data[i] = {peak_val = 0}
  end
    
  -- Get the sample rate. MIDI source media will return zero.
  local take_source_sample_rate = reaper.GetMediaSourceSampleRate(take_pcm_source)
  if take_source_sample_rate == 0 then
    return
  end
  
  local take_vol = reaper.GetMediaItemTakeInfo_Value(take, "D_VOL")
  
  --[[
  -- Get the media source type ("WAV", "MIDI", etc) to typebuf  
  take_source_type = reaper.GetMediaSourceType(take_pcm_source, "")
  --]]
  

  -- how many samples are taken from audio accessor and put in the buffer
  local samples_per_channel = take_source_sample_rate / 10 -- (f.ex. 44100/10 = 4410)
  
  -- Samples are collected to this buffer
  local buffer = reaper.new_array(samples_per_channel * take_source_num_channels)
  
  local take_start_offset = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
  local take_playrate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
  --take_pos = item_pos-start_offs

  
  local total_samples = math.ceil((aa_end - aa_start) * take_source_sample_rate)
  --total_samples = math.floor((aa_end - aa_start) * take_source_sample_rate)
  --total_samples = (aa_end - aa_start) * take_source_sample_rate
  
  local block = 0
  
  --local peak_val = 0
  local sample_count = 0
  local audio_end_reached = false
  
  local abs = math.abs
  local floor = math.floor
  local log = math.log
  local offs = aa_start
  
  while sample_count < total_samples do
    if audio_end_reached then
      break
    end
   -- if offs + samples_per_channel*take_source_num_channels / take_source_sample_rate >= aa_end then
     -- break
    --end
    -- Get a block of samples from the audio accessor.
    -- Samples are extracted immediately pre-FX,
    -- and returned interleaved (first sample of first channel, 
    -- first sample of second channel...). Returns 0 if no audio, 1 if audio, -1 on error.
    local aa_ret = reaper.GetAudioAccessorSamples
                                                (
                                                  aa,                       -- AudioAccessor accessor
                                                  take_source_sample_rate,  -- integer samplerate
                                                  take_source_num_channels, -- integer numchannels
                                                  offs,                     -- number starttime_sec
                                                  samples_per_channel,      -- integer numsamplesperchannel
                                                  buffer                    -- reaper.array samplebuffer
                                                )
      
    if aa_ret <= 0 then
      --msg("no audio or other error")
      --return
    end
    
    for i=1, #buffer, take_source_num_channels do --samples_per_channel * take_source_num_channels do
      if sample_count == total_samples then
        audio_end_reached = true
        break
      elseif not audio_end_reached then
      
        for j=1, take_source_num_channels do
          local buf_pos = i+j-1
          local curr_val = abs(buffer[buf_pos])
          if curr_val > channel_data[j].peak_val then
            -- store current peak value for this channel
            channel_data[j].peak_val = curr_val
            -- store current peak sample index for this channel
            channel_data[j].peak_sample_index = sample_count
          end
        end
        sample_count = sample_count + 1--take_source_num_channels
      end
    end
    block = block + 1
    offs = offs + samples_per_channel / take_source_sample_rate -- new offset in take source (seconds)
  end
  reaper.DestroyAudioAccessor(aa)
  
  local max_peak_val = 0
  local channel = 0
  local peak_sample_index = -1
  
  for i=1, take_source_num_channels do
    if channel_data[i].peak_val > max_peak_val then
      -- get max peak value from "channel_data" table
      max_peak_val = channel_data[i].peak_val
      -- get peak sample index from "channel_data" table
      peak_sample_index = channel_data[i].peak_sample_index 
      -- max_peak_val found -> store current channel index
      channel = i
    end
    msg("Channel " .. i .. " peak: " .. 20*math.log(channel_data[i].peak_val*take_vol*item_vol, 10)) -- max val in decibels
  end
  
  msg("Highest peak: Channel " .. channel .. ": " .. 20*math.log(max_peak_val*take_vol*item_vol, 10)) -- max val in decibels
  msg("\n")
  
  local cursor_pos = item_pos + peak_sample_index/take_source_sample_rate
  reaper.SetEditCurPos(cursor_pos, true, false)
  reaper.UpdateArrange()
end

function main()
  go_to_peak_sample()
end

main()

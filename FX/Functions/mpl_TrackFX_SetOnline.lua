  function TrackFX_SetOnline(track, id, on)
    local chunk,chunk_opened
    _, chunk = reaper.GetTrackStateChunk(track, '')
      
    -- chain table
      local chunk_t = {}
      for line in chunk:gmatch("[^\n]+") do  table.insert(chunk_t, line)  end
      
    -- extract fx chunks limits
      local fx_chunks_limits = {}
      for i = 1, #chunk_t do
        if chunk_t[i]:find('BYPASS') ~= nil then
          chunk_opened = true
          table.insert(fx_chunks_limits, {i})
        end
        if chunk_t[i]:find('WAK') ~= nil and chunk_opened then
          chunk_opened = false
          fx_chunks_limits[#fx_chunks_limits][2]=i
        end            
      end  
      
    -- set byp 
      local t = {}   
      for word in chunk_t[fx_chunks_limits[id+1][1]]:gmatch('[^%s]+') do t[#t+1] = word end        
      t[3] = on
      
    -- set chunk    
      chunk_t[fx_chunks_limits[id+1][1]] = table.concat(t, ' ')
      reaper.SetTrackStateChunk(track, table.concat(chunk_t, '\n'))
  end
  
  track = reaper.GetTrack(0,0)
  test = TrackFX_SetOnline(track, 0, 1)

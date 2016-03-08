  function TrackFX_GetOnline(track, id)
    local chunk,chunk_opened
    _, chunk = reaper.GetTrackStateChunk(track, '')
      local chunk_t = {}
    -- chain table
      for line in chunk:gmatch("[^\n]+") do  table.insert(chunk_t, line)  end
    -- extract fx chunks limits
      fx_chunks_limits = {}
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
    return chunk_t[fx_chunks_limits[id+1][1]]:sub(10,10)&1==0             
  end
  
  track = reaper.GetTrack(0,0)
  test = TrackFX_GetOnline(track, 0)

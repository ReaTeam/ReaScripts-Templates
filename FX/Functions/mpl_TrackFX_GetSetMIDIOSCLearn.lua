 function TrackFX_GetSetMIDIOSCLearn(track_in, fx_index, param_id, is_set, string_midiosc)
   -- is_set == 0 - get
   -- is_set == -1 - remove all learn from pointed parameter
   
   -- return midichan,midicc, osclearn
   -- if in_chan == -1 then remove learn for current param
   if fx_index == nil then return end
   fx_index = fx_index+1 -- 0-based    
                 --param_id 0-based
                 
   local out_midi_num, chunk,exists, guid_id,chunk_t,i,fx_chunks_t,fx_count,
     fx_guid,param_count,active_fx_chunk,active_fx_chunk_old,active_fx_chunk_t,
     out_t,midiChannel,midiCC,insert_begin,insert_end,active_fx_chunk_new,main_chunk,temp_s
     
   if track_in == nil then reaper.ReaScriptError('MediaTrack not found') return end
   _, chunk = reaper.GetTrackStateChunk(track, '')      
   --reaper.ShowConsoleMsg(chunk)
   if reaper.TrackFX_GetCount(track) == 0 then reaper.ReaScriptError('There is no FX on track') return end
   if fx_index > reaper.TrackFX_GetCount(track) then reaper.ReaScriptError('FX index > Number of FX') return end
   -- get com table
     main_chunk = {}
     for line in chunk:gmatch("[^\n]+") do 
       table.insert(main_chunk, line)
     end
     
   -- get fx chunks
     chunk_t= {}
     temp_s = nil
     i = 1
     for line in chunk:gmatch("[^\n]+") do 
       if temp_s ~= nil then temp_s = temp_s..'\n'..line end
       if line:find('BYPASS') ~= nil then
         temp_s = i..'\n'..line
       end
       if line:find('WAK') ~= nil then  
         table.insert(chunk_t, temp_s..'\n'..i)  
         temp_s = nil 
       end
       i = i +1
     end
   
   -- filter fx chain, ignore rec/item
     fx_chunks_t = {}
     fx_count = reaper.TrackFX_GetCount(track)
     for i = 1, fx_count do
       fx_guid = reaper.TrackFX_GetFXGUID(track, i-1)
       for k = 1, #chunk_t do
         if chunk_t[k]:find(fx_guid:sub(-2)) ~= nil then table.insert(fx_chunks_t, chunk_t[k]) end
       end
     end
     if #fx_chunks_t ~= fx_count then return nil end
     if fx_index > fx_count then reaper.ReaScriptError('FX index > Number of FX')  return end
     
     param_count = reaper.TrackFX_GetNumParams(track, fx_index-1)
     if param_id+1 > param_count then reaper.ReaScriptError('Parameter index > Number of parameters') return end
     
   -- filter active chunk
     active_fx_chunk = fx_chunks_t[fx_index]
     active_fx_chunk_old = active_fx_chunk
     
   -- extract table
     active_fx_chunk_t = {}
     for line in active_fx_chunk:gmatch("[^\n]+") do table.insert(active_fx_chunk_t, line) end
 
   -- get first param
     for i = 1, #active_fx_chunk_t do
       if active_fx_chunk_t[i]:find('PARMLEARN '..param_id..' ') then exists = i break end
     end 
      
     --------------------------      
     if is_set == 0 then -- GET 
       if exists == nil then reaper.ReaScriptError('There is no learn for current parameter') return end
       -- form out table
         out_t = {}
         for word in active_fx_chunk_t[exists]:gsub('PARMLEARN ', ''):gmatch('[^%s]+') do
           table.insert(out_t, word)
         end
       -- convert
         midiChannel = out_t[2] & 0x0F
         midiCC = out_t[2] >> 8    
         
       return midiChannel + 1, midiCC, out_t[4] 
     end
     
     --------------------------
     if is_set == 1 then -- SET  midi
       if string_midiosc ~= nil and string_midiosc ~= '' then
       
           -- add to active_fx_chunk_t
             for i = 1, #active_fx_chunk_t do
               if active_fx_chunk_t[i]:find('FXID ') then guid_id = i break end
             end
             
             table.insert(active_fx_chunk_t, guid_id+1,
               'PARMLEARN '..param_id..' '..string_midiosc)
       end 
     end
       
       
     --------------------------  
     if is_set == -1 then -- remove current parameters learn
         for i = 1, #active_fx_chunk_t do
           if active_fx_chunk_t[i]:find('PARMLEARN '..param_id..' ') then 
             active_fx_chunk_t[i] = ''
           end
         end       
     end
     --------------------------   
           
     if is_set == -1 or is_set == 1 then
       -- return fx chunk table to chunk
         insert_begin = active_fx_chunk_t[1]
         insert_end = active_fx_chunk_t[#active_fx_chunk_t]
         active_fx_chunk_new = table.concat(active_fx_chunk_t, '\n', 2, #active_fx_chunk_t-1)
         
         
       -- delete_chunk lines
         for i = insert_begin, insert_end do
           table.remove(main_chunk, insert_begin)
         end
       
       -- insert new fx chunk
         table.insert(main_chunk, insert_begin, active_fx_chunk_new)
         
       -- clean chunk table from empty lines
         local out_chunk = table.concat(main_chunk, '\n')
         local out_chunk_clean = out_chunk:gsub('\n\n', '')
         --reaper.ShowConsoleMsg(out_chunk_clean)
         reaper.SetTrackStateChunk(track, table.concat(main_chunk, '\n')) 
     end
 end
 
   
   track  = reaper.GetTrack(0,0)  
   TrackFX_GetSetMIDIOSCLearn(track, 
                      0, --fx_index 0 -based,
                      1, --param_id 0-based
                      1, --is_set
                      '0 0 /1/fader1' --string_midiosc
                      )
                      
   --[[string_midiosc = (midiCC << 8) | 0xB0 + midiChan - 1 ..
                    is_soft_takeover ..
                    osc_address]]

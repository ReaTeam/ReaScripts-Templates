  function ReplaceFXChain(track, file)
 local out_chunk ,content 
	
  content = file:read('a')  
    --------
    function ExtractBlock(str)
      local s = ''
      local count = 1
      for line in str:gmatch('[^\n]+') do
        s = s..'\n'..line
        if line:find('<') then count = count +1 end
        if line:find('>') then count = count -1 end 
        if count == 1 then return s end     
      end
    end
    -------
    local def_chain = 
[[<FXCHAIN
WNDRECT 24 52 655 408
SHOW 0
LASTSEL 0
DOCKED 0
]]
    -------
    if track ~= nil then
      local _, chunk = reaper.GetTrackStateChunk(track, '')    
      local fx_chain_st = chunk:find('<FXCHAIN')
      if fx_chain_st == nil then 
        _, fx_chain_st = chunk:find('MAINSEND %d %d\n') 
        out_chunk = 
          chunk:sub(0,fx_chain_st)..
          def_chain..
          new_chain..
          '>'..
          chunk:sub(fx_chain_st)
       else
        local str_e = ExtractBlock(chunk:sub(fx_chain_st))
        out_chunk = chunk:sub(0,fx_chain_st-1)..
        def_chain..
        new_chain..
        '>'
        ..chunk:sub(fx_chain_st+str_e:len()-1)
        
      end
      --reaper.ShowConsoleMsg(out_chunk)
      reaper.SetTrackStateChunk(track, out_chunk)    
    end
  end  
  
  
  
  file = io.open('C:/test.RfxChain', 'r')
  track = reaper.GetSelectedTrack(0,0)
  ReplaceFXChain(track, file)

-- require REAPER v30

reaper.ClearConsole()
tcnt=reaper.CountTracks(0)
for t=1,tcnt do
  tr=reaper.GetTrack(0,t-1)
  icnt=reaper.CountTrackMediaItems(tr)
  for i=1,icnt do
    item=reaper.GetTrackMediaItem(tr,i-1)
    tk=reaper.GetActiveTake(item)
    if tk ~= nil then
      ok,buf=reaper.MIDI_GetAllEvts(tk,"")
      if ok and buf:len() > 0 then
        reaper.ShowConsoleMsg(string.format("\nTrack %d, item %d:\n", t, i))
        edit=false
        pos=1
        while pos <= buf:len() do
        
          offs,flag,msg=string.unpack("IBs4",buf,pos)
          adv=4+1+4+msg:len() -- int+char+int+msg
          
          out="+"..offs.."\t"
          for j=1,msg:len() do out=out..string.format("%02X ",msg:byte(j)) end
          if flag ~= 0 then out=out.."\t" end
          if flag&1 == 1 then out=out.."sel " end
          if flag&2 == 2 then out=out.."mute " end
          reaper.ShowConsoleMsg(out.."\n")

          --[[
          -- some examples of how MIDI could be altered and pushed back to the project
          if msg:byte(1)&0xF0 == 0x90 then
            -- convert all note-ons to velocity 96
            newmsg=string.pack("BBB",msg:byte(1),msg:byte(2),0x60)
            repl=string.pack("IBs4",offs,flag,newmsg)
            buf=buf:sub(1,pos-1)..repl..buf:sub(pos+adv)                          
            edit=true
          elseif msg:byte(1) == 0xFF and msg:byte(2) == 0x01 then
            -- convert all text events to "reaper"    
            newmsg=string.pack("BBc6",0xFF,0x01,"reaper") -- z instead of c6 would encode trailing NULL
            repl=string.pack("IBs4",offs,flag,newmsg)
            buf=buf:sub(1,pos-1)..repl..buf:sub(pos+adv)
            adv=adv+newmsg:len()-msg:len()
            edit=true
          end
          --]]
          
          pos=pos+adv          
        end
        
        if edit == true then
          -- this will destructively change the MIDI source data!
          reaper.MIDI_SetAllEvts(tk,buf)
          reaper.ShowConsoleMsg("edited!\n")          
        end            
      end
    end
  end
end

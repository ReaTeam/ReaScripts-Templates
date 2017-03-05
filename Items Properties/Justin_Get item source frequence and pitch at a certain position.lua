-- http://forum.cockos.com/showpost.php?p=1777001&postcount=2
-- REAPER v32

item = reaper.GetSelectedMediaItem(0,0);
take = reaper.GetMediaItemTake(item,0);
nch = reaper.GetMediaSourceNumChannels(reaper.GetMediaItemTake_Source(take));

ns = 1;
buf = reaper.new_array(ns*3*nch);
rv = reaper.GetMediaItemTake_Peaks(take,1000.0, reaper.GetCursorPosition(),nch,ns,115,buf);
if rv & (1<<24) and (rv&0xfffff) > 0 then
  spl = buf[nch*ns*2 + 1];
  reaper.MB(string.format("Pitch: %d Hz, tonality %f",spl&0x7fff,(spl>>15)/16384.0),"hi",0);
end


-- X-Raym Mod
-- same thing as a function
function GetSourceItemFrequencyAtPosition( take, pos )
  local source = reaper.GetMediaItemTake_Source(take)
  local nch = reaper.GetMediaSourceNumChannels(source)
  local ns = 1
  local buf = reaper.new_array(ns*3*nch)
  local rv = reaper.GetMediaItemTake_Peaks(take,1000.0,pos,nch,ns,115,buf)
  if rv & (1<<24) and (rv&0xfffff) > 0 then
    local spl = buf[nch*ns*2 + 1]
    return tonumber(string.format("%d",spl&0x7fff))
   end 
end

item = reaper.GetSelectedMediaItem(0,0)
if item then
  take = reaper.GetActiveTake(item,0)
  if take and not reaper.TakeisMIDI(take) then
    pos = reaper.GetCursorPosition()
    freq = GetSourceItemFrequencyAtPosition( take, pos )
  end
 end 
 

-- X-Raym Mod
-- same thing as a function for loops
function GetSourceItemFrequencyAtPosition2( take, pos, nch, ns, buf )
  local rv = reaper.GetMediaItemTake_Peaks(take,1000.0,pos,nch,ns,115,buf)
  if rv & (1<<24) and (rv&0xfffff) > 0 then
    local spl = buf[nch*ns*2 + 1]
    return tonumber(string.format("%d",spl&0x7fff))
   end 
end

item = reaper.GetSelectedMediaItem(0,0)
if item then
  take = reaper.GetActiveTake(item,0)
  if take and not reaper.TakeisMIDI(take) then
    pos = reaper.GetCursorPosition()
    source = reaper.GetMediaItemTake_Source(take)
    nch = reaper.GetMediaSourceNumChannels(source)
    ns = 1
    buf = reaper.new_array(ns*3*nch)
    freq = GetSourceItemFrequencyAtPosition2( take, pos, nch, ns, buf )
  end
 end 

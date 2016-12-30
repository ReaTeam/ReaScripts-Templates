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

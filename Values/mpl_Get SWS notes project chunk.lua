   function GetSWSNotes(track)
    if not track or not reaper.ValidatePtr2( 0, track, 'MediaTrack*' )  then return end  
    local _, projfn = reaper.EnumProjects( -1 , '' )
    local f = io.open(projfn, 'r')
    if not f then return end 
    local context = f:read('a')   
    f:close()    
    local match_pattern = '<S&M_TRACKNOTES '.. reaper.GetTrackGUID( track )
    local match_str = match_pattern:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end)
    local str = context:match(match_str..'%s+(.-)%s+>')
    return str
  end
  
  tr = reaper.GetSelectedTrack(0,0)
  track_notes = GetSWSNotes(tr)

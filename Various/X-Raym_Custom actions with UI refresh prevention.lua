reaper.PreventUIRefresh(1) -- Prevent UI Refresh

-- Duplicate and modify the order of the two following lines at will.
reaper.Main_OnCommand( 4000, 0 )-- Call to native Actions. Replace 4000 by your choosen Command ID. Command ID can be found in the action list.
reaper.Main_OnCommand( reaper.NamedCommandLookup( "_SWS_SELTRKWITEM"),  0 ) -- Call to SWS Actions. Replace "_SWS_SELTRKWITEM" by Command ID of your SWS action.

reaper.PreventUIRefresh(-1) -- Restore UI Refresh

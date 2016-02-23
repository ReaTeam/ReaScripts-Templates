reaper.PreventUIRefresh(1) -- Prevent UI Refresh

reaper.Main_OnCommand(4000, 0)-- Call to native Actions. Command ID can be found in the action list.
reaper.Main_OnCommand( reaper.NamedCommandLookup("_SWS_SELTRKWITEM"),  0) -- Call to SWS Actions.

reaper.PreventUIRefresh(-1) -- Restore UI Refresh

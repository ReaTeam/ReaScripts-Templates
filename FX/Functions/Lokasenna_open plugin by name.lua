--[[
  by Lokasenna

  Searches through the project for the first instance of the
  specified FX and toggles its window open/closed.
  
  Can be handy to bind to a key for accessing a plugin you use
  a lot, i.e. open_plugin_by_name("EZDrummer")
]]--

function open_plugin_by_name(plugin_name)

  track_count = reaper.CountTracks(0)

	for i = 0, track_count - 1 do
	
	track_current = reaper.GetTrack(0, i)
	plugin_id = reaper.TrackFX_GetByName(track_current, plugin_name, 0)
	
		if plugin_id ~= -1 then
			
			already_open = reaper.TrackFX_GetOpen(track_current, plugin_id)
	
			if already_open then
				
				reaper.TrackFX_Show(track_current, plugin_id, 2)
				
			else
			
				reaper.TrackFX_Show(track_current, plugin_id, 3)
				
			end
			
			return
		
		end
		
	end	

end

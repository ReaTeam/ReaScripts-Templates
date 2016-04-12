-- This is not finished. It will not work in a lot of cases.
-- I uploaded it here as a demo.

-- ----------> USER CONFIG AREA --------------------> 
target_fx_name = "VST: ReaComp (Cockos)" -- UTILISER STRING FIND ou lister tous les parametres ?
target_param_name = "Wet"
target_value = "-20"

is_vol = "true"
-- <----------  <------------- END OF USER CONFIG AREA

function Msg(string)
	reaper.ShowConsoleMsg(tostring(string).."\n")
end

function Main()

	count_sel_tracks = reaper.CountSelectedTracks(0)
	
	if count_sel_tracks > 0 then
		
		retval, retvals_csv = reaper.GetUserInputs("Set FX param value", 4, "FX,Param,Value,dB Scale", target_fx_name..","..target_param_name..","..target_value..","..is_vol) 
			
		if retval then -- if user complete the fields
	
			target_fx_name, target_param_name, target_value, is_vol = retvals_csv:match("([^,]+),([^,]+),([^,]+),([^,]+)")
			
			target_value = tonumber(target_value)
			
			if is_vol == "true" then
				target_value = math.exp( target_value * 0.115129254 )
			end

			for i = 0, count_sel_tracks - 1 do
			
				track = reaper.GetSelectedTrack(0, i)
			
				-- LOOP FX
				count_fx = reaper.TrackFX_GetCount(track)
				
				for j = 0, count_fx - 1 do
					
					fx_name_retval, fx_name = reaper.TrackFX_GetFXName(track, j, "")
					--Msg(fx_name)
					x, y = string.find(fx_name, target_fx_name)
					
					if x ~= nil then
					
						count_params = reaper.TrackFX_GetNumParams(track, j)
						
						for k = 0, count_params - 1 do
							
							param_retval, minval, maxval = reaper.TrackFX_GetParam(track, j, k)
							
							param_name_retval, param_name = reaper.TrackFX_GetParamName(track, j, k, "")
							
							param_val_retval, param_val = reaper.TrackFX_GetFormattedParamValue(track, j, k, "")
							
							--Msg(param_name..param_val)
							
							w, z = string.find(param_name, target_param_name)
							
							if w ~= nil then

								--reaper.TrackFX_SetParamNormalized(track, j, k, "1")
								reaper.TrackFX_SetParam(track, j, k, target_value)

								break
								
							end
							
						end
						
					end
					
				end
			
			end
			
		end
		
	end
	
end

Main()

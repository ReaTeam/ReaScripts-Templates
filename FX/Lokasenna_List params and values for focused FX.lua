local function Msg(str)
	reaper.ShowConsoleMsg(tostring(str).."\n")
end

local retval, tracknumberOut, itemnumberOut, fxnumberOut = reaper.GetFocusedFX()

tracknumberOut = reaper.GetTrack( 0, tracknumberOut - 1 )

local parms = {}

if not retval or retval == 0 then
	
	return 0 
	
elseif retval == 1 then

	__, parms.name = reaper.TrackFX_GetFXName( tracknumberOut, fxnumberOut, "")
	local num = reaper.TrackFX_GetNumParams( tracknumberOut, fxnumberOut )
	for i = 1, num do		  
		local ret, pname = reaper.TrackFX_GetParamName( tracknumberOut, fxnumberOut, i, "" )
		local val, minvalOut, maxvalOut = reaper.TrackFX_GetParam( tracknumberOut, fxnumberOut, i )		
		local ret, fval = reaper.TrackFX_GetFormattedParamValue( tracknumberOut, fxnumberOut, i, "" )		
		--Msg(i.." - "..tostring(name)..": "..tostring(val).." ("..tostring(fval)..")")		
		table.insert(parms, {pname, val, fval})

	end	
	
elseif retval == 2 then

	local takenumberOut, fxnumberOut = fxnumberOut & 0xFFFF, fxnumberOut >> 16
	local item = reaper.GetTrackMediaItem( tracknumberOut, itemnumberOut )

	if not item then return 0 end

	local take = reaper.GetMediaItemTake( item, takenumberOut )
	
	if not take then return 0 end
	
	__, parms.name = reaper.TakeFX_GetFXName( take, fxnumberOut, "")
	local num = reaper.TakeFX_GetNumParams( take, fxnumberOut)
	for i = 1, num do
	
		local ret, pname = reaper.TakeFX_GetParamName( take, fxnumberOut, i, "" )
		local val, minvalOut, maxvalOut = reaper.TakeFX_GetParam( take, fxnumberOut, i )
		local ret, fval = reaper.TakeFX_GetFormattedParamValue( take, fxnumberOut, i, "")
		table.insert(parms, {pname, val, fval})	
	
	end
	
end

Msg("Listing parameters for "..tostring (parms.name).."\n" )
for i = 1, #parms do
	Msg("\t"..i.." - "..tostring(parms[i][1]))
	Msg("\t\tReal value: "..tostring(parms[i][2]).."\n\t\tFormatted: "..tostring(parms[i][3]))
end

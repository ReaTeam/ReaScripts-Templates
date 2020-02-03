function GetMarkerOrRegionAtPos( pos )
	local vals = {}
	local markeridx, regionidx = reaper.GetLastMarkerAndCurRegion( 0, pos )
	if regionidx then
		local retval, isrgn, start, rgnend, name, idx = reaper.EnumProjectMarkers( regionidx )
		vals.region_name = name
		vals.region_idx = idx
	end
	if markeridx then
		local retval, isrgn, start, rgnend, name, idx = reaper.EnumProjectMarkers( markeridx )
		if start == pos then
			vals.marker_name = name
			vals.marker_idx = idx
		end
	end
	return vals
end

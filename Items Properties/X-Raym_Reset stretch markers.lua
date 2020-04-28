      take_num_stretch_markers =  reaper.GetTakeNumStretchMarkers( take )
      s_markers = {}
      for j = 0, take_num_stretch_markers - 1 do
        retval, s_pos, s_srcpos = reaper.GetTakeStretchMarker( take, j )
        s_markers[j+1] = { pos = s_pos, s_srcpos = s_srcpos, slope = reaper.GetTakeStretchMarkerSlope( take, j  )}
      end
      for j = 0, take_num_stretch_markers - 1 do
        reaper.SetTakeStretchMarker( take, j, s_markers[j+1].s_srcpos, s_markers[j+1].s_srcpos )
        reaper.SetTakeStretchMarkerSlope( take, j, 0 )
      end

-- YOUR ACTION

      for j = 0, take_num_stretch_markers - 1 do
        reaper.SetTakeStretchMarker( take, j, s_markers[j+1].pos, s_markers[j+1].s_srcpos )
        reaper.SetTakeStretchMarkerSlope( take, j, s_markers[j+1].slope )
      end

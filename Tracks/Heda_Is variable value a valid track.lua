function Is_Valid_Track(track)

  valid_track=reaper.ValidatePtr(track, "MediaTrack*")

  return valid_track

end

function GetEnvelopePointsByTimes(env)
  local tab = {}
  local count_points = reaper.CountEnvelopePoints(env)
  for i = 0, count_points -1 ,do
    local entry = {id=i}
    local retval, time, entry.value, entry.shape, entry.tension, entry.selected = reaper.GetEnvelopePoint( env, i )
    tab[time] = entry
  end
  return tab
end

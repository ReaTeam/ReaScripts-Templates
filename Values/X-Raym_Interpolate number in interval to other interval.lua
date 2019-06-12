function MapLInear (num, in_min, in_max, out_min, out_max)
  return (num - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

print( map( 5, 0, 100, 0, 200) )

function print( ...)
  local t = {}
  for i, v in ipairs( { ... } ) do
    t[i] = tostring( v )
  end
  reaper.ShowConsoleMsg( table.concat( t, "\n" ) .. "\n" )
end

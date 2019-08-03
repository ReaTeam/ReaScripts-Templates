function EnumerateFiles( folder )
  local files = {}
  local i = 0
  repeat
    files[i] = reaper.EnumerateFiles( folder, i )
  until not retval
  return files
end

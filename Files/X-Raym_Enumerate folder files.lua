function EnumerateFiles( folder )
  local files = {}
  local i = 1
  repeat
    files[i] = reaper.EnumerateFiles( folder, i )
    i = i + 1
  until not retval
  return files
end

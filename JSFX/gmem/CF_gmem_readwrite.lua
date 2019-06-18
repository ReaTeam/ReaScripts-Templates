function gmem_write_string(index, value)
  for c in value:gmatch('.') do
    reaper.gmem_write(index, string.byte(c))
    index = index + 1
  end

  reaper.gmem_write(index, 0)
end

function gmem_read_string(index)
  local chars = {}

  while true do
    local value = reaper.gmem_read(index)
    if value == 0 then break end

    table.insert(chars, string.char(value))
    index = index + 1
  end

  return table.concat(chars)
end
